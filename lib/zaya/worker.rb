# frozen_string_literal: true

module Zaya
  module Worker
    include Zaya::Logging

    module ClassMethods
      attr_accessor :queue_name, :exclusive
      attr_writer :durable

      def max_priority=(priority)
        queue_arguments["x-max-priority"] = priority
      end

      def message_ttl=(ttl)
        queue_arguments["x-message-ttl"] = ttl
      end

      def queue_arguments
        @queue_arguments ||= {}
      end

      def durable
        @durable ||= true
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    # Internal #perform.
    # @private
    def _perform(ctx)
      Zaya.middleware.invoke(ctx) do
        perform(ctx)
      end
    rescue Exception => e # rubocop:disable Lint/RescueException
      # Report exception to the app exception reporting service.
      Zaya.report_exception_method
          .call(e, worker_klass: self.class.name, queue: self.class.queue_name)

      ctx.exception = e
      ctx.reject!
    ensure
      ctx.reject! if ctx.noop?
    end
  end
end
