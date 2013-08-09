require File.expand_path("../boot", __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "sprockets/railtie"

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => ["development", "test"]))
end

module ZapfolioPortfolio
  class Application < Rails::Application
    Dir[Rails.root.join("shared/mongo_mapper/**/*.rb")].each {|f| require f}
    Dir[Rails.root.join("lib/jobs/**/*.rb")].each {|f| require f}

    unless Rails.env.worker?
      config.sass.load_paths << "#{Gem.loaded_specs['compass-susy-plugin'].full_gem_path}/sass"
    end

    config.autoload_paths += [Rails.root.join("lib"), Rails.root.join("shared", "models")]

    config.filter_parameters += [:password, :password_confirmation]

    config.assets.enabled = true
    config.assets.precompile << "css_editor.js"
    config.assets.precompile << "core_pages.css"
    config.assets.precompile << "reset.css"
    config.assets.precompile << /layout_([a-z]+)\.css$/
    config.assets.precompile << "libraries/*.css"

    config.exceptions_app = self.routes

    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.yml")]

    Haml::Template.options[:format] = :html5

    config.encoding = "utf-8"
  end
end
