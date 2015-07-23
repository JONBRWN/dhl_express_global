require 'rspec'
require 'dhl_express_global'
require 'support/vcr'
require 'support/credentials'

RSpec.configure do |c|
  c.filter_run_excluding :production unless dhl_production_credentials
  c.expect_with :rspec do |expect_config|
    expect_config.syntax = :expect
  end
end