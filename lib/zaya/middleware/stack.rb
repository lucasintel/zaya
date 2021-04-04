# frozen_string_literal: true

module Zaya
  module Middleware
    class Stack
      def initialize
        @stack = []
      end

      def prepend(klass, *args)
        entry = Entry.new(klass, *args)
        @stack.unshift(entry)
      end

      def add(klass, *args)
        entry = Entry.new(klass, *args)
        @stack.push(entry)
      end
      alias use add

      def remove(klass)
        @stack.delete_if { |entry| entry.klass == klass }
      end
      alias rm remove

      def invoke(ctx)
        return yield if @stack.empty?

        stack = @stack.map(&:build)

        traverse_stack = proc do
          if stack.empty?
            yield
          else
            stack.shift.call(ctx, &traverse_stack)
          end
        end

        traverse_stack.call
      end
    end
  end
end
