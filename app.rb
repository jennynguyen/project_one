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
    #Happy note: I can use logger.info "_: #{}" anywhere
    #to check my errors.
    logger.info "Response Headers: #{response.headers}"
  end

  ########################
  # DB Configuration
  ########################

  #ENV["REDISTOGO_URL"]) is saved in my .bash_profile
  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])

  ########################
  # Routes
  ########################

  get('/') do
    #my main page
    # render(:erb, :home_page)
    # redirect to("/posts")
    redirect to("/signup")
  end


  get("/signup") do
    render(:erb, :signup)
  end


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
    # Generate unique index for each post
    index = $redis.incr("post:index")
    # Generate json form
    #keys are: index, title, content
    post = { id: index, title: title, content: content}
    # Set json form with key in redis
    #Happy note: need to have a space between "post: #{}"
    #or else the code won't work.
    #learned to use logger.info "_: #{}" here to stop and check for error
    #is it similar to binding.pry??????
    $redis.set("posts: #{index}", post.to_json)
    redirect to("/posts")
  end

  # GET /posts/new
  get("/posts/new") do
    render(:erb, :new_post)
  end

  # GET /posts/1
  get("/posts/:id") do
    #_id, _raw_post are local variables.
    #They only exist here within this method.
    #Happy note: spent 18 hours to figure it out. Totally worth it!
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
  #update post base
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
  #NEED TO FIRGURE OUT HOW TO ALLOW USERS TO REALLY BE ABLE TO SIGN UP!!!
  #as for now sign up ang sign in don't work => they both lead to the posts I wrote.
  post ('/signup') do
    redirect("/posts")
  end


  #for users to sign up
  #same problem as above. Merde!!!!!!!
  post ('/signin') do
    redirect("/posts")
  end






end
