require './application_controller'

class App < ApplicationController

  get('/') do
    redirect to("/signup")
  end

  get("/signup") do
    render(:erb, :signup)
  end

  get("/signin") do
    render(:erb, :signin)
  end

  get("/posts") do
    id = params["first"].to_i || 0
    posts = $redis.keys("*posts*").map { |post| JSON.parse($redis.get(post)) }
    # posts = $redis.keys("*posts*").map { |post| JSON.parse($redis.get(post)) }
    @posts = posts[id, 10]
    @posts.sort_by! {|hash| hash["id"] }
    render(:erb, :index)
  end

  post("/posts") do
    title = params[:title]
    content = params[:mce_0]
    index = $redis.incr("post:index")
    post = { id: index, title: title, content: content}
    $redis.set("posts: #{index}", post.to_json)
    redirect to("/posts")
  end

  get("/posts/new") do
    render(:erb, :new)
  end

  get("/posts/:id") do
    _id = params[:id]
    _raw_post = $redis.get("posts: #{_id}")
    @post = JSON.parse(_raw_post)
    render(:erb, :show)
  end

  get("/posts/:id/edit") do
    id = params[:id]
    raw_post = $redis.get("posts: #{id}")
    @post = JSON.parse(raw_post)
    render(:erb, :edit)
  end

  put("/posts/:id") do
    _title = params[:new_post_title]
    _content = params[:mce_0]
    _id = params[:id].to_i
    updated_post = {id: _id, title: _title, content: _content}
    $redis.set("posts: #{_id}", updated_post.to_json)
    redirect to("/posts")
  end

  delete("/posts/:id") do
    id = params[:id]
    $redis.del("posts: #{id}")
    redirect to("/posts")
  end

  # NOT yet work
  post ('/signup') do
      redirect("/posts")
  end


  # NOT yet work
  post ('/signin') do
    redirect("/posts")
  end

  get('/rss/:id') do
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
    rss.to_s
  end

end
