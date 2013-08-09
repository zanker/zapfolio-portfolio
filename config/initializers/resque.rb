require "resque/failure/multiple"
require "resque/failure/redis"
require "resque/failure/airbrake"

env = ENV["RAILS_ENV"] || Rails.env
Resque.redis = YAML.load_file(File.join(File.expand_path(File.dirname(__FILE__) + "/../"), "redis.yml"))[env]
Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
Resque::Failure.backend = Resque::Failure::Multiple