class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = MoneyTransfer.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, :notice => "User Created." }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, :notice => "User updated." }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def show
    @user = User.find(params[:id])
    @money_transfers = MoneyTransfer.between_users(current_user.id, @user.id) unless current_user == @user
  end

  protected

  def user_params
    params.require(:user).permit([:email, :password])
  end
end
