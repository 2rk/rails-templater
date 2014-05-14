require 'rspec'

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# ensure that we have a network connection to the internet before running any of these tests.
begin
  require 'net/http'
  Net::HTTP.get("google.com", '/')
rescue Interrupt
  exit 0
rescue StandardError
  puts "Network offline!"
  exit 1
end

# load support files:
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.use_transactional_fixtures = false

  # include any other modules

  # add global before/after blocks:

end

# turn of deprecation warning.
I18n.enforce_available_locales = false
