# frozen_string_literal: true

# See https://github.com/rails/rails/issues/54263
require "logger"

# Load the Rails application.
require File.expand_path("application", __dir__)

# Initialize the Rails application.
Dummy::Application.initialize!
