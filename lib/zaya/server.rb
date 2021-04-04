# frozen_string_literal: true

module Zaya
  class Server
    BANNER = <<~TXT

      /\\ /\\
      ( . .) zaya

      Starting processing, hit Ctrl-C to stop

    TXT

    SIGNAL_HANDLERS = {
      "TERM" => -> { raise Interrupt },
      "INT" => -> { raise Interrupt }
    }.freeze

    def self.start(formation)
      $stdout.puts BANNER

      begin
        SIGNAL_HANDLERS.each do |signal, handler|
          trap signal do
            handler.call
          end
        end

        formation.start
        sleep
      rescue Interrupt
        Zaya.logger.info("Received graceful stop")
        formation.stop
        Zaya.logger.info("Done")
      end
    end
  end
end
