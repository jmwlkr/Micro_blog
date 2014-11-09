require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'sinatra/flash'

set :database, 'sqlite3:formdemo.sqlite3'
enable :sessions

# This method is accessible in all of our erb files!! COOL RIGHT!
def current_user
  if session[:user_id].nil?
    @user = nil
  else
    @user = User.find(session[:user_id])
  end
end

#### INDEX ROUTE ####

get "/" do
  @posts = Post.all

  # @followers = @user.followers
  # @following = @user.leaders

  erb :index
end

#### SIGNUP ####

get "/signup" do
  erb :signup
end

post "/signup" do
  if User.where(email: params[:user][:email]).first
    flash[:alert] = "That Email is taken!"
    redirect "/"
  end

  @user = User.new(params[:user])

  if @user.save
    session[:user_id] = @user.id
    flash[:notice] = "Successfully Signed Up"
  else
    flash[:alert] = "The Account was not successfully created"
  end

  redirect "/"
end

#### LOGIN AND LOGOUT ####

post "/login" do
  @user = User.where(email: params[:email]).first

  if @user && @user.password == params[:password]
    session[:user_id] = @user.id
    flash[:notice] = "Logged In Successful!"
  else
    flash[:alert] = "Invalid Attempt"
  end

  redirect "/"
end

get "/logout" do
  session[:user_id] = nil
  redirect "/"
end

#### PROFILE ROUTES ####

get "/profile/:id" do
  @user = User.find(params[:id])
  @profile = @user.profile
  erb :profile
end

#### POSTS ROUTES ####

get "/posts" do
  @posts = Post.all

  erb :posts
end

get "/post/new" do
  erb :new_post
end

post "/post/new" do
  @post = Post.new(text: params[:text],
                   user_id: session[:user_id])

  if @post.save
    flash[:notice] = "Post was Successfully Created"
  end

  redirect "/"
end

get "/post/:id/delete" do
  @post = Post.find(params[:id])

  if @post.user_id != session[:user_id]
    flash[:alert] = "YOU ARE NOT THAT USER"
  else
    if @post.destroy
      flash[:notice] = "THE POST WAS DESTROYED"
    end
  end

  redirect "/"
end
