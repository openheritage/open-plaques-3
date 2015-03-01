require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

I18n.enforce_available_locales = true

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OpenPlaques
  class Application < Rails::Application

    config.secret_key_base = ENV['SECRET_KEY_BASE']
    
    config.time_zone = 'London'

    config.logger = Logger.new(STDOUT)

    config.assets.version = '1.0'

    config.i18n.default_locale = :"en-GB"
    config.i18n.fallbacks =[:en]

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
