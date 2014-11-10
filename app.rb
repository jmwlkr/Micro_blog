require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'sinatra/flash'

set :database, 'sqlite3:formdemo.sqlite3'
enable :sessions

# This method is accessible in all of our erb files!! COOL RIGHT!
def current_user
  if session[:user_id].nil?
    @current_user = nil
  else
    @current_user =  User.find(session[:user_id])
  end
  return @current_user
end

#### INDEX ROUTE ####

get "/" do
  current_user
  @posts = Post.all

  # @followers = @user.followers
  # @following = @user.leaders

  erb :index
end

#### SIGNUP ####

get "/signup" do
  current_user
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

get "/user/:id" do
  @user = User.find(params[:id])
  current_user
  @profile = @user.profile
  @posts = @user.posts
  @follow = Follower.where(follower_id: session[:user_id],
                           leader_id: params[:id]).first

  erb :user
end

post "/profile/new" do
  current_user

  if @current_user && !@current_user.profile.nil?
    @profile = @current_user.profile

    if @profile.update(params[:profile])
      flash[:notice] = "Profile Updated"
    else
      flash[:alert] = "The Profile was not updated!"
    end

  elsif @current_user && !@current_user.profile

    @profile = Profile.new(bio: params[:profile][:bio],
                           user_id: session[:user_id])
    if @profile.save
      flash[:notice] = "Profile Created"
    else
      flash[:alert] = "The Profile was not Created!"
    end

  else
    flash[:alert] = "Something went terribly wrong"
  end

  redirect "/user/#{ @current_user.id }"
end

#### FOLLOWERS ROUTS ####

get "/user/:id/follow" do
  @follow = Follower.new(follower_id: session[:user_id], leader_id: params[:id])
  if @follow.save
    flash[:notice] = "You are now following this User"
  else
    flash[:alert] = "Something went wrong!"
  end

  redirect "/user/#{params[:id]}"
end

get "/follow/:id/delete" do
  @follow = Follower.find(params[:id])


  if @follow.follower_id != session[:user_id]
    flash[:alert] = "YOU ARE NOT THAT USER"
  else

    if @follow.destroy
      flash[:notice] = "You are no longer following this User"
    else
      flash[:alert] = "Something went wrong!"
    end

  end

  redirect back
end

#### POSTS ROUTES ####

get "/posts" do
  current_user
  @posts = Post.all

  erb :posts
end

get "/post/new" do
  current_user

  erb :new_post
end

post "/post/new" do
  @post = Post.new(text: params[:text],
                   user_id: session[:user_id])

  if @post.save
    flash[:notice] = "Post was Successfully Created"
  else
    flash[:alert] = "Something went wrong!"
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
    else
      flash[:alert] = "Something went wrong!"
    end
  end

  redirect "/"
end
