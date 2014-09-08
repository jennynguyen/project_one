require 'sinatra/base'
require 'redis'
require 'pry'
require 'json'

class App < Sinatra::Base

  ########################
  # Configuration
  ########################

  configure do
    enable :logging
    enable :method_override
    enable :sessions
  end

  before do
    logger.info "Request Headers: #{headers}"
    logger.warn "Params: #{params}"
  end

  after do
    logger.info "Response Headers: #{response.headers}"
  end

  ########################
  # DB Configuration
  ########################

  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])

  ########################
  # Routes
  ########################

  get('/') do
    # render(:erb, :home_page)
    # redirect to("/posts")
    redirect to("/signup")
  end

  # GET /posts
  get("/signup") do
    render(:erb, :signup)
  end

  # GET /posts
  get("/signin") do
    render(:erb, :signin)
  end


  # GET /posts
  get("/posts") do
     @posts = $redis.keys("*posts*").map { |post| JSON.parse($redis.get(post)) }
    render(:erb, :index)
  end

  # POST /posts
  post("/posts") do
    # passing parameters from post
    title = params[:title]
    content = params[:content]
    # Generate unique index
    index = $redis.incr("post:index")
    # Generate Json form
    post = { id: index, title: title, content: content}
    # Set Json form with Key in redis
    $redis.set("posts: #{index}", post.to_json)
    redirect to("/posts")
  end

  # GET /posts/new
  get("/posts/new") do
    render(:erb, :new_post)
  end

  # GET /posts/1
  get("/posts/:id") do
    _id = params[:id]
    _raw_post = $redis.get("posts: #{_id}")
    @post = JSON.parse(_raw_post)
    render(:erb, :show)
  end

  # GET /posts/1/edit
  get("/posts/:id/edit") do
    id = params[:id]
    raw_post = $redis.get("posts: #{id}")
    @post = JSON.parse(raw_post)
    render(:erb, :edit_form)
  end

  # PUT /posts/1
  put("/posts/:id") do
    _title = params[:new_post_title]
    _content = params[:new_post_content]
    _id = params[:id]
    updated_post = {id: _id, title: _title, content: _content}
    $redis.set("posts: #{_id}", updated_post.to_json)
    redirect to("/posts")
  end

  # DELETE /posts/1
  delete("/posts/:id") do
    id = params[:id]
    $redis.del("posts: #{id}")
    redirect to("/posts")
  end

  #for users to sign up
  post ('/signup') do
    redirect("/posts")
  end


  #for users to sign up
  post ('/signin') do
    redirect("/posts")
  end






end
