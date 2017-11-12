Dir.glob("#{Rails.root}/vendor/assets/**").each do |path|
  Rails.application.config.assets.paths << path
end
Dir.glob("#{Rails.root}/app/assets/images/flags/**").each do |path|
  Rails.application.config.assets.paths << path
end
Rails.application.config.assets.precompile += %w( worcester_serial-regular-webfont.eot )
Rails.application.config.assets.precompile += %w( worcester_serial-regular-webfont.svg )
Rails.application.config.assets.precompile += %w( worcester_serial-regular-webfont.ttf )
Rails.application.config.assets.precompile += %w( worcester_serial-regular-webfont.woff )
Rails.application.config.assets.precompile += %w( worcester_serial-regular-webfont.woff2 )
Rails.application.config.assets.precompile += %w( people.css )
Rails.application.config.assets.precompile += %w( plaques.css )
Rails.application.config.assets.precompile += %w( more_columns.css )
# Rails.application.config.assets.precompile += %w( person.css )
# Rails.application.config.assets.precompile += %w( photo.css )
Rails.application.config.assets.precompile += %w( flag-icon.css )
Rails.application.config.assets.precompile += %w( vendor/assets/fonts/* )
