ZapfolioPortfolio::Application.configure do
  Haml::Template.options[:ugly] = true

  config.action_controller.page_cache_directory = "public/cache"

  config.action_controller.asset_host = "//d3h9d5zx6uh3mr.cloudfront.net"

  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  config.cache_classes = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.serve_static_assets = false

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  config.cache_store = :dalli_store, {:namespace => "port", :expires_in => 1.day}

  config.sass.cache_store = Sass::CacheStores::Dalli.new

  # Passenger has a bug where when using "listen 443 default ssl" (or anything besides "ssl on"), it won't set the HTTPS env. We have to check for port to fix that.
  # http://code.google.com/p/phusion-passenger/issues/detail?id=401&colspec=ID%20Type%20Status%20Priority%20Milestone%20Stars%20Summary
  module ActionDispatch
    module Http
      module URL
        def ssl?
          @env['HTTPS'] == 'on' || @env['HTTP_X_FORWARDED_PROTO'] == 'https' || @env['SERVER_PORT'].to_i == 443
        end
      end
    end
  end

  # Figure out asset ids for caching
  ASSET_IDS = {:latest => File.read("#{Rails.root}/REVISION").strip}

  js_log = `git log -n 1 #{Rails.root}/app/assets/javascripts`
  js_modified = Time.parse(js_log.match(/Date: (.+)/i)[1]).utc

  css_log = `git log -n 1 #{Rails.root}/app/assets/stylesheets`
  css_modified = Time.parse(css_log.match(/Date: (.+)/i)[1]).utc

  ASSET_IDS[:javascripts] = js_log.match(/commit ([a-z0-9]+)/i)[1]
  ASSET_IDS[:stylesheets] = css_log.match(/commit ([a-z0-9]+)/i)[1]
  ASSET_IDS[:compiled] = (js_modified > css_modified) ? ASSET_IDS["javascripts"] : ASSET_IDS["stylesheets"]
end
