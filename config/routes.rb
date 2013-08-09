ZapfolioPortfolio::Application.routes.draw do
  get "/site-assets/:website_id/restyle/:layout(/:modified)" => "site_assets#restyled_data", :as => :site_asset_restyle
  get "/site-assets/:website_id/fragment/:fragment(/:modified).css" => "site_assets#fragment", :as => :site_asset_fragment
  get "/site-assets/:website_id(/:modified).css" => "site_assets#show", :as => :site_asset
  get "/robots.txt" => "site_assets#robots"
  get "/sitemap.xml" => "site_assets#sitemap"

  controller :contacts, :path => :contacts, :as => :contact do
    post "/send/:page_id", :action => :create
  end

  controller :pages do
    post "/login" => :login

    get "/*a/:page", :action => :show, :constraints => {:page => /[0-9]+/}
    get "/*a", :action => :show
    get "/", :action => :home
  end
end
