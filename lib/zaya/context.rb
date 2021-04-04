# frozen_string_literal: true

module Zaya
  class Context
    attr_reader :channel, :delivery_info, :metadata
    attr_accessor :worker, :payload, :exception

    def initialize(channel, delivery_info, metadata, payload)
      @channel = channel
      @delivery_info = delivery_info
      @metadata = metadata
      @payload = payload
      @exception = nil
      @success = false
      @acked = false
      @rejected = false
    end

    # Acknowledges the message delivery (see #acked?).
    def ack!
      return if acked? || rejected?

      channel.acknowledge(delivery_info.delivery_tag)
      @acked = true
      @success = true
    end

    # Rejects the message delivery (see #rejected?).
    def reject!(requeue: true)
      return if acked? || rejected?

      channel.reject(delivery_info.delivery_tag, requeue)
      @rejected = true
      @success = false
    end

    # @return [Boolean] true if the task was sucessful.
    def success?
      !!@success
    end

    # @return [Boolean] true if the task failed with an exception.
    def exception?
      !exception.nil?
    end

    # @return [Boolean] true if the message was acknowledged.
    def acked?
      !!@acked
    end

    # @return [Boolean] true if the message was rejected.
    def rejected?
      !!@rejected
    end

    # @return [Boolean] true if the message was not answered.
    def noop?
      !acked? && !rejected?
    end
  end
end
