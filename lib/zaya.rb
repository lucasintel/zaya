# frozen_string_literal: true

require "bunny"
require "concurrent"
require "errbase"
require "logger"
require "optionparser"

require_relative "zaya/logger"
require_relative "zaya/cli"
require_relative "zaya/consumer"
require_relative "zaya/consumer_monitor"
require_relative "zaya/context"
require_relative "zaya/formation"
require_relative "zaya/middleware"
require_relative "zaya/server"
require_relative "zaya/utils"
require_relative "zaya/version"
require_relative "zaya/worker"

module Zaya
  class << self
    DEFAULT_REPORT_EXCEPTION_METHOD = ->(e, ctx) { Errbase.report(e, ctx) }

    attr_writer :connection, :logger, :report_exception_method

    # Configuration for Zaya server.
    #
    # @example
    #   Zaya.configure do |config|
    #     config.connection = Bunny.new(ENV["CLOUDAMQP_URL"], heartbeat: 0)
    #     config.logger = Logger.new($stdout)
    #     config.prepend Instrumentation
    #     config.use Statistics
    #   end
    def configure
      yield(self)
    end

    # @return [Bunny::Session] the RabbitMQ connection.
    def connection
      @connection ||= Bunny.new
      @connection.start unless connected?
    end

    # @return [Boolean] true if the RabbitMQ connection is open.
    def connected?
      @connection.connected?
    end

    # @return [Zaya::Middleware::Stack] the middleware stack.
    def middleware
      @middleware ||= Zaya::Middleware::Stack.new
    end

    # Proc called when Zaya silences an exception. By default, exceptions
    # are reported to your reporting service.
    #
    # @return [Proc]
    def report_exception_method
      @report_exception_method ||= DEFAULT_REPORT_EXCEPTION_METHOD
    end

    # @return [Logger] Zaya logger.
    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.formatter = Zaya::LogFormatter.new
      end
    end

    # @return [String] Zaya version.
    def version
      VERSION
    end
  end
end
