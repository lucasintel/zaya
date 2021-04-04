# frozen_string_literal: true

require "zaya"

class MinimalWorker
  include Zaya::Worker

  self.queue_name = "greetings"

  def perform(ctx)
    puts ctx.payload
    ctx.ack!
  end
end
