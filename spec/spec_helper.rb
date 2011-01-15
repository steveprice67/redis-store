require 'bundler/setup'
Bundler.require(:default)

require 'action_dispatch'
require 'active_support'
require 'redis_store'

RSpec.configure do |config|
  config.mock_with :rspec
end
