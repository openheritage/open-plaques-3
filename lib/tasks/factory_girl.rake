namespace :factory_girl do
  desc 'Verify that all FactoryBot factories are valid'
  task lint: :environment do
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        FactoryBot.lint
      ensure
        DatabaseCleaner.clean
      end
    else
      system('bundle exec rake factory_girl:lint RAILS_ENV=test')
    end
  end
end
