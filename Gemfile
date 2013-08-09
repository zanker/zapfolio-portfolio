source "https://rubygems.org"

gem "rails", "~>3.2.8"

gem "kaminari", "~>0.13.0"

gem "dragonfly", "~>0.9.12"

gem "fog"

gem "mongo_mapper", "~>0.11.1"
gem "mongo", "~>1.6.2"
gem "bson_ext", "~>1.6.2"

gem "haml", "~>3.1.4"

gem "bcrypt-ruby", "~>3.0.1"

gem "json", "~>1.7.0"

gem "airbrake"

gem "resque", "~>1.20.0"

group :worker do
  gem "mail", "~>2.4.4"
end

group :production do
  gem "dalli", "~>2.1.0"
  gem "kgio", "~>2.7.4"
end

group :assets do
  gem "sprockets"

  gem "jquery-rails"

  gem "therubyracer", :platform => :ruby
  gem "uglifier", ">= 1.0.3"
end

group :assets, :production do
  gem "sass-rails"
  gem "sass", "~>3.2.0.alpha.104"

  gem "compass"
  gem "compass-rails"
  gem "compass-susy-plugin"
end

group :development do
  gem "thin"

  gem "capistrano"
  gem "capistrano_colors"

  gem "rails-dev-tweaks"
end

group :development, :test do
  gem "request_profiler"
end

group :test do
  gem "capybara"

  gem "rspec"
  gem "rspec-rails"

  gem "guard"
  gem "guard-rspec"

  gem "factory_girl"
  gem "factory_girl_rails"

  gem "timecop"
end