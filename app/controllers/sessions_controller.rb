class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(username: params[:session][:username].strip.downcase)
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      flash[:top] = "You have successfully logged in"
      redirect_to user_path(user)
    else
      flash.now[:top] = "Username or password is incorrect"
      render 'new'
    end
  end

  def destroy
    if !logged_in?
      session[:user_id] = nil
      flash[:top] = "You are not logged in!"
      redirect_to root_path
    else
      session[:user_id] = nil
      flash[:top] = "You have successfully logged out."
      redirect_to root_path
    end
  end

end