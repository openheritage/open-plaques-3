class UsersController < ApplicationController

  before_filter :authenticate_admin!, :except => [:new, :create]
  
  unless Rails.env == 'development'
    before_filter :authenticate_admin!, :only => [:new, :create]
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find_by_username!(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if Rails.env == 'development' && User.count == 0
      @user.is_admin = true
    end

    if @user.save
      flash[:notice] = "Account created. You can now sign in the user you just created."
      redirect_to root_path
    else
      render :new
    end
  end
  
end
