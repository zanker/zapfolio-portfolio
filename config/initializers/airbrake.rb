Airbrake.configure do |config|
  config.secure = false
  config.api_key = "c8bf02bd544ea3649e0d19cf9f8f9b89"

  ZapfolioPortfolio::Application.config.filter_parameters.each {|p| config.params_filters << p}
end