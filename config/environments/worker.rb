ZapfolioPortfolio::Application.configure do
  ASSET_IDS = {}

  Haml::Template.options[:ugly] = true

  config.action_controller.page_cache_directory = "public/cache"

  config.cache_classes = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.serve_static_assets = false

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.log_level = :info
end
