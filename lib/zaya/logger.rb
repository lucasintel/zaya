# frozen_string_literal: true

require "time"

module Zaya
  class LogFormatter < ::Logger::Formatter
    def call(_severity, timestamp, progname, msg)
      if progname
        "#{timestamp.utc.iso8601} PID:#{process_id} [#{progname}] #{msg}\n"
      else
        "#{timestamp.utc.iso8601} PID:#{process_id} #{msg}\n"
      end
    end

    private

    def process_id
      Process.pid
    end
  end

  module Logging
    def logger
      Zaya.logger
    end
  end
end
