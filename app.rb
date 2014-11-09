require 'sinatra'
require 'sinatra/activerecord'
require './models'
require 'sinatra/flash' # require 'bundler'
                        # require 'rack-flash'

# user Rack::Flash, sweep => true
set :database, 'sqlite3:formdemo.sqlite3'
enable :sessions

def current_user
  if session[:user_id].nil?
    @user = nil
  else
    @user = User.find(session[:user_id])
  end
end

get "/" do
  @user = current_user
  @posts = Post.all

  # @followers = @user.followers
  # @following = @user.leaders

  erb :index
end

get "/posts" do

end

get "/signup" do
  erb :signup
end

post "/signup" do
  puts params.inspect
  if User.where(email: params[:user][:email]).first
    flash[:alert] = "That Email is taken!"
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

get "/post/:potato/delete" do
  puts "HEY THERE!!!"
  p params
  puts "----"
  p params[:potato]
  @post = Post.find(params[:potato])
  if @post.user_id != session[:user_id]
    flash[:alert] = "YOU ARE NOT THAT USER"
  else
    if @post.destroy
      flash[:notice] = "THE POST WAS DESTROYED"
    end
  end
  redirect "/"
end
