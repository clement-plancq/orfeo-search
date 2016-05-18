# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

if ENV['ORFEO_SEARCH_ROOT']
  Rails.application.config.action_controller.relative_url_root = ENV['ORFEO_SEARCH_ROOT']
end

# Add additional assets to the asset load path
Rails.application.config.assets.paths += %w( vendor/assets/javascripts vendor/assets/stylesheets )

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( bootstrap-table.js bootstrap-table.css )
