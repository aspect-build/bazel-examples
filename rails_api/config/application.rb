# frozen_string_literal: true

require "active_support"
require "active_support/parameter_filter"
require "active_support/core_ext"
require "action_controller/railtie"

module RailsApi
  class Application < Rails::Application
    config.load_defaults 7.1
    config.api_only = true
    config.eager_load = false
    config.secret_key_base = "test_secret_key_base_for_development"
    config.active_support.cache_format_version = 7.1
  end
end

# Explicitly require controllers since Rails autoloading doesn't work in Bazel sandbox
require_relative "../app/controllers/application_controller"
require_relative "../app/controllers/health_controller"
require_relative "../app/controllers/items_controller"
