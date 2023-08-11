# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PriceWebParser
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = 'Samara'
    # config.eager_load_paths << Rails.root.join("extras")
    config.generators do |g|
      g.test_framework :rspec
    end
    config.autoload_paths << Rails.root.join('lib')
    config.i18n.default_locale = :ru

    config.before_configuration do
      env_file = Rails.root.join('.env')
      if File.exist?(env_file)
        require 'dotenv'
        Dotenv.load(env_file)
      end
    end
  end
end
