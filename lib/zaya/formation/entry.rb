# frozen_string_literal: true

module Zaya
  class Formation
    class Entry
      attr_reader :worker_class, :concurrency

      def initialize(worker_class, concurrency)
        @worker_class = worker_class
        @concurrency = concurrency
        freeze
      end
    end
  end
end
