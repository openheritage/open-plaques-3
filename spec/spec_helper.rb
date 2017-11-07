# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
# require 'rspec/autorun'
# require 'capybara/rspec'
# require 'capybara/email/rspec'
# require 'capybara/webkit/matchers'

# Capybara.javascript_driver = :webkit

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  # config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # JavaScript tests break unless we disable transactional fixtures and
  # use database_cleaner gem instead.
  config.use_transactional_fixtures = false
  config.before(:each) do |example|
    DatabaseCleaner.strategy =
      example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end

  # only accept new RSpec syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


RSpec::Matchers.define :include_one_of do |*elements|
  match do |actual|
    @included = []
    elements.flatten.each do |e|
      @included << e if actual.include?(e)
    end
    @included.count == 1
  end

  failure_message do |actual|
    "expected \n  \"#{actual}\"\nto include one of \n  \"#{expected.join("\"\n  \"")}\""
  end
end

RSpec::Matchers.define :be_one_of do |*elements|
  match do |actual|
    @included = []
    elements.flatten.each do |e|
      @included << e if actual.eql?(e)
    end
    @included.count == 1
  end

  failure_message do |actual|
    "expected \n  \"#{actual}\"\nto include one of \n  \"#{expected.join("\"\n  \"")}\""
  end
end
