# frozen_string_literal: true

module Zaya
  module CLI
    class << self
      FORMATION_ENV_KEY = "FORMATION"

      def run(args = ARGV)
        OptionParser.new do |parser|
          parser.on("-r", "--require [PATH]") do |path|
            load path
          end
        end.parse!(args)

        # Load the formation from the environment.
        formation = Zaya::Formation.from_formation_string(ENV[FORMATION_ENV_KEY])

        Zaya::Server.start(formation)
      end
    end
  end
end
