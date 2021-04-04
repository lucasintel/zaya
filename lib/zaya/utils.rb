# frozen_string_literal: true

module Zaya
  module Utils
    WHITESPACE_INSENSITIVE_REGEX = /\s+/.freeze
    WORKER_DELIMITER = ","
    CONCURRENCY_DELIMITER = "="
    DEFAULT_CONCURRENCY = 1

    def self.extract_workers(string)
      return {} if string.nil? || string.empty?

      worker_strings = string
                       .gsub(WHITESPACE_INSENSITIVE_REGEX, "")
                       .split(WORKER_DELIMITER)

      worker_strings.each_with_object({}) do |worker_string, hash|
        worker_klass_string, concurrency_string = worker_string.split(CONCURRENCY_DELIMITER)
        concurrency = [concurrency_string.to_i, DEFAULT_CONCURRENCY].max

        klass = Object.const_get(worker_klass_string)

        hash[klass] = concurrency
      end
    end

    def self.generate_consumer_id(consumer)
      "#{consumer.worker_klass}-PID:#{Process.pid}-CID:#{object_id.to_s(36)}"
    end
  end
end
