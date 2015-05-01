class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :admin_only, except: [:show, :index]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    return unless current_user.admin?
    redirect_to :back, alert: 'Access denied.' unless @user == current_user
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(secure_params)
      redirect_to users_path, notice: 'User updated.'
    else
      redirect_to users_path, alert: 'Unable to update user.'
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    redirect_to users_path, notice: 'User deleted.'
  end

  private

  def admin_only
    redirect_to :back, alert: 'Access denied.' unless current_user.admin?
  end

  def secure_params
    params.require(:user).permit(:role)
  end
end
