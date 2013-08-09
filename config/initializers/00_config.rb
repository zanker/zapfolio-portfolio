data = YAML::load(File.read(File.join(File.expand_path(File.dirname(__FILE__) + "/../"), "site_config.yml")))
CONFIG = data[ENV["RAILS_ENV"] || Rails.env]
