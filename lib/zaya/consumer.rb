# frozen_string_literal: true

module Zaya
  class Consumer
    include Zaya::Logging

    attr_reader :worker_klass, :concurrency

    def initialize(worker_klass, concurrency)
      @worker_klass = worker_klass
      @concurrency = concurrency

      @consumer_id = Zaya::Utils.generate_consumer_id(self)

      @channel = Zaya.connection.create_channel
      @channel.prefetch(concurrency)

      @queue = @channel.queue(worker_klass.queue_name,
                              arguments: worker_klass.queue_arguments,
                              durable: worker_klass.durable,
                              exclusive: worker_klass.exclusive)

      @thread_pool = Concurrent::FixedThreadPool.new(concurrency)

      freeze
    end

    def start
      logger.info(@consumer_id) { "up (x#{@concurrency})" }

      @queue.subscribe(consumer_tag: @consumer_id, manual_ack: true) do |*args|
        @thread_pool.post do
          ctx = Context.new(@channel, *args)

          worker = @worker_klass.new
          ctx.worker = worker

          worker._perform(ctx)
        end
      end
    end

    def graceful_stop
      @channel.basic_cancel(@consumer_id)
      @thread_pool.shutdown
    ensure
      @channel.close
    end

    def immediate_stop
      @channel.close
      @thread_pool.kill
    end

    def running?
      @thread_pool.running? || @thread_pool.shuttingdown?
    end

    def stopped?
      !running?
    end
  end
end
