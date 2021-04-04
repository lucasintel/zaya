# frozen_string_literal: true

module Zaya
  module Middleware
    class Entry
      attr_accessor :klass

      def initialize(klass, *args)
        @klass = klass
        @args = args
      end

      def build
        if @args&.any?
          @klass.new(*args)
        else
          @klass.new
        end
      end
    end
  end
end
