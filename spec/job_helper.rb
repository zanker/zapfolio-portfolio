ENV["RAILS_ENV"] ||= "test"

unless defined?(CONFIG)
  require "resque"
  require "factory_girl"

  require File.expand_path("../../config/initializers/00_config.rb", __FILE__)
  require File.expand_path("../../config/initializers/resque.rb", __FILE__)
  Dir[File.expand_path("../../lib/jobs/**/*.rb", __FILE__)].each {|f| require f}
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.include FactoryGirl::Syntax::Methods
end