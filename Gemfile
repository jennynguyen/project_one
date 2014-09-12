source 'https://rubygems.org'

ruby "2.1.2"

# Gems used in every environment
# default groups
gem 'sinatra',  '1.4.5', require: 'sinatra/base'
gem 'redis',    '3.1.0'
gem 'httparty', '0.13.1'
gem 'ffaker'
gem 'actionview', '~> 4.1.5', require: "action_view"

# only used in development locally
group :development, :test do
  gem 'pry',     '0.10.1'
  gem 'shotgun', '0.9'
  gem 'sinatra-contrib', require: 'sinatra/reloader'
end

# gems specific just in the production environment
group :production do
end

group :test do
  gem 'rspec',    '~> 3.0.0'
  gem 'capybara', '~> 2.4.1'
end
