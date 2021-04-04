# frozen_string_literal: true

module Zaya
  class ConsumerMonitor
    def initialize(consumer)
      @consumer = consumer
      @thread = Thread.new { @consumer.start }
      freeze
    end

    def graceful_stop
      @consumer.graceful_stop if running?
    end

    def immediate_stop
      @consumer.immediate_stop if running?
    end

    def stopped?
      @consumer.stopped? && @thread.stop?
    end

    def running?
      !stopped?
    end
  end
end
