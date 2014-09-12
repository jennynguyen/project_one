require './helpers/application_helper'

class ApplicationController < Sinatra::Base

  enable :logging
  enable :method_override
  enable :sessions
  set :session_secret, 'super secret'

  helpers ApplicationHelper

  configure :development do
    register Sinatra::Reloader
  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])
  # $redis.flushdb

end
