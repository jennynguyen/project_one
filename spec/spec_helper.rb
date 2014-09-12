ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'capybara/rspec'
require './app'

Capybara.app = App

RSpec.configure do |config|
  config.include Capybara::DSL
end

