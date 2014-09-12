require 'rubygems'
require 'bundler'

# require 'sinatra/base'
# require 'httparty'
# require 'redis'
# require 'pry' if ENV['RACK_ENV'] == "development"
# require 'sinatra/reloader' if ENV['RACK_ENV'] == "development"
# require 'ffaker'
# Bunler.require will take care of all the gems above
# Use Bundler to load up all the dependencies
# loading up all the gems that I had to previously write require for
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require './app'
run App
