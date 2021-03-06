require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KokoroIo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.generators do |g|
      g.test_framework = 'rspec'
    end

    config.autoload_paths += %W["#{config.root}/app/validators"]

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # For API
    # config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    # config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]

    config.to_prepare do
      # Only Applications list
      Doorkeeper::ApplicationsController.layout "application"
      # Only Authorization endpoint
      Doorkeeper::AuthorizationsController.layout "application"
      # Only Authorized Applications
      Doorkeeper::AuthorizedApplicationsController.layout "application"
    end

  end
end
