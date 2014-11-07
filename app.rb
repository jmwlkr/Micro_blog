require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'sinatra/flash' # require 'bundler'
                        # require 'rack-flash'

# user Rack::Flash, sweep => true
set :database, 'sqlite3:formdemo.sqlite3'
enable :sessions

get "/" do
  if session[:user_id].nil?
    @user = nil
  else
    @user = User.find(session[:user_id])
  end
  @posts = Post.all
  @followers = @user.followers
  @following = @user.leaders

  erb :index
end

get "/signup" do
  erb :signup
end

post "/signup" do
  puts params.inspect
  if User.where(params[:user].email).first
    flash[:alert] = "You Stink"
    redirect "/"
  end
  @user = User.new(params[:user])
  if @user.save
    session[:user_id] = @user.id
    flash[:notice] = "Successfully Signed Up"
  else
    flash[:alert] = "You Stink"
  end
  redirect "/"
end

post "/login" do
  @user = User.where(email: params[:email]).first
  if @user && @user.password == params[:password]
    session[:user_id] = @user.id
    flash[:notice] = "Great You got in!"
  else
    flash[:alert] = "Invalid Attempt"
  end
  redirect "/"
end

get "/logout" do 
  session[:user_id] = nil
  redirect "/"
end

get "/post/new" do
  erb :new_post
end

post "/post/new" do
  @post = Post.new(text: params[:text], 
                   user_id: session[:user_id])
  if @post.save
    flash[:notice] = "Successfully Created Post"
  else
    flash[:alert] = "Your Post was not Created"
  end
  redirect "/"
end


