# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

if ENV["COVERAGE"] == "true"
  require "simplecov"
  SimpleCov.start do
    enable_coverage :branch

    add_filter "/spec/"
    add_filter "/lib/generators/"
  end

  require "simplecov-lcov"
  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = "coverage/lcov.info"
  end

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

ENV["RUBY_NEXT_TRANSPILE_MODE"] = "rewrite"
ENV["RUBY_NEXT_EDGE"] = "1"
require "ruby-next/language/runtime" unless ENV["CI"]

require "logger"

require "action_policy"
begin
  require "pry-byebug"
rescue LoadError
end

require_relative "../test/stubs/user"

require "ammeter"
require "action_policy/rspec"

require File.expand_path("dummy/config/environment", __dir__)

RSpec.configure do |config|
  config.mock_with :rspec

  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "tmp/.rspec-status"

  # For silence_stream
  # TODO: Drop after deprecating Rails 4.2
  if defined?(ActiveSupport::Testing::Stream)
    include ActiveSupport::Testing::Stream
  else
    include(Module.new do
      def silence_stream(stream)
        old_stream = stream.dup
        stream.reopen(IO::NULL)
        stream.sync = true
        yield
      ensure
        stream.reopen(old_stream)
        old_stream.close
      end
    end)
  end
end
