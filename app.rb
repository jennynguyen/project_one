require 'sinatra/base'
require 'redis'
# require 'pry'
require 'json'
require 'rss'
require 'redistogo'

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

  #ENV["REDISTOGO_URL"]) is saved in .bash_profile
  #reset redis by adding .fushdb
  $redis = Redis.new(:url => ENV["REDISTOGO_URL"])
  # $redis.flushdb

  ########################
  # Routes
  ########################

  #main page
  get('/') do
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
    id = params["first"].to_i || 0
    #iterate through all the datas' keys stored as redis
    #return a new array with json database format
    #so that I can call methods on them
     posts = $redis.keys("*posts*").map { |post| JSON.parse($redis.get(post)) }
     # @posts = $redis.keys("*posts*").map { |post| JSON.parse($redis.get(post)) }
    @posts = posts[id, 10]
    #sort the array of @posts by id, from lowest
    # binding.pry
    @posts.sort_by! {|hash| hash["id"] }
    #binding.pry
    #IT KEEPS BREAKING HERE.
    #THERE'S SOMETHING WRONG WITH COMPARISION
    #THE FIRST INDEX ALWAYS RETURNS AS A STRING
    #INSTEAD AS AN INTERGER
    #HAVE TO .FLUSHDB AND ADD NEW POSTS AGAIN
    render(:erb, :index)
  end

  # create a new post, increase counter by 1
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
    $redis.set("posts: #{index}", post.to_json)
    # redirect go /posts
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
  #update post using id
  put("/posts/:id") do
    _title = params[:new_post_title]
    _content = params[:new_post_content]
    _id = params[:id]
    updated_post = {id: _id, title: _title, content: _content}
    #$redis key is "post: #{_id}"
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
    # codes don't work. merde!
    # before '/posts/*' do
    #  authenticate!
    # end
    redirect("/posts")
  end

  get ('/rss/:id') do
    id = params[:id]
    title = params[:title]

    rss = RSS::Maker.make("atom") do |maker|
      maker.channel.author = "Jennifer Nguyen"
      maker.channel.updated = Time.now.to_s
      maker.channel.about = "localhost:9393/rss"
      maker.channel.title = "Blogs Feeds"

      maker.items.new_item do |item|
        item.link = "/posts/#{:id}"
        item.title = "/posts/#{:title}"
        item.updated = Time.now.to_s
      end
    end

  # puts rss
  @rss = rss
  # binding.pry
  #can not render erb file.
  #it returns a string. For now there's nothing in my content.
  # render(:erb, @rss)
  render(:erb, @rss.to_s)
  end

end
