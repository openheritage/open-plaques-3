Rails.application.config.generators do |g|
  g.test_framework :rspec, view_specs: false,
                           controller_specs: false,
                           request_specs: false,
                           routing_specs: false
  g.stylesheets false
  g.javascripts false
end
