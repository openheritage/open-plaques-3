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

 #   config.i18n.enforce_available_locales = false
    config.i18n.available_locales = [:'en-GB', :fr, :en]
    config.i18n.default_locale = :'en-GB'
    config.i18n.fallbacks =[:en]

  end
end
