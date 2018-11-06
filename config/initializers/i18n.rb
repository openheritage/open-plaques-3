module OpenPlaques
  class Application < Rails::Application
    config.secret_key_base = ENV['SECRET_KEY_BASE']
    config.time_zone = 'London'
    config.logger = Logger.new(STDOUT)
    config.action_mailer.default_url_options = { host: ENV['HOST'] || "http://localhost:#{ENV['PORT']}"  }
    config.assets.version = '1.0'
 #   config.i18n.enforce_available_locales = false
#    config.i18n.available_locales = [:'en-GB', :fr, :en, :ru]
    config.i18n.available_locales = [:'en-GB', :en]
    config.i18n.default_locale = :'en-GB'
    config.i18n.fallbacks = [:en]
  end
end
