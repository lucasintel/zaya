# frozen_string_literal: true

require_relative "lib/zaya/version"

Gem::Specification.new do |spec|
  spec.name = "zaya"
  spec.version = Zaya::VERSION
  spec.summary = "Simple queue processor for Ruby and RabbitMQ"
  spec.homepage = "https://github.com/kandayo/zaya"
  spec.license = "MIT"

  spec.author = "kandayo"
  spec.email = "kdy@absolab.xyz"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/kandayo/zaya/blob/main/CHANGELOG.md"

  spec.files = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path = "lib"
  spec.executables = "zaya"

  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.add_dependency "bunny", "~> 2.17"
  spec.add_dependency "concurrent-ruby", "~> 1.1"
  spec.add_dependency "errbase"
end
