# frozen_string_literal: true

require_relative "formation/entry"

module Zaya
  class Formation
    include Zaya::Logging

    GRACEFUL_STOP_ATTEMPTS = 12
    WAIT_INTERVAL = 2

    def self.from_formation_string(string)
      instance = new
      specifications = Zaya::Utils.extract_workers(string)

      specifications.each do |worker_klass, concurrency|
        instance.add(worker_klass, concurrency)
      end

      instance
    end

    def initialize
      @entries = Set.new
      @monitors = Set.new
      freeze
    end

    # Add a consumer specification to the formation.
    def add(worker_class, concurrency)
      @entries << Entry.new(worker_class, concurrency)
    end

    # Remove an entry from the formation.
    def remove(worker_class)
      @entries.delete_if { |entry| entry.worker_class == worker_class }
    end
    alias rm remove

    def start
      @entries.each do |entry|
        consumer = Zaya::Consumer.new(entry.worker_class, entry.concurrency)
        monitor = Zaya::ConsumerMonitor.new(consumer)
        @monitors << monitor
      end

      @monitors.freeze
      @entries.freeze
    end

    def stop
      logger.info("Pausing to allow consumers to finish...")
      @monitors.each(&:graceful_stop)

      shutdown_wait_loop do
        return if @monitors.all?(&:stopped?)
      end

      shutdown
    rescue Interrupt
      shutdown
    end

    private

    def shutdown_wait_loop
      GRACEFUL_STOP_ATTEMPTS.times do
        sleep WAIT_INTERVAL
        yield
      end
    end

    def shutdown
      logger.info("Killing remaining consumers.")
      @monitors.each(&:immediate_stop)
    end
  end
end
