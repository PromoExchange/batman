class Spree::Admin::LogosController < Spree::Admin::ResourceController
  before_action :load_user
  before_action :load_logo, only: [:destroy, :show]
  before_action :set_custom, only: :create

  private

  def load_logo
    @logo = Spree::Logo.find params[:id]
  end

  def load_user
    @user = Spree::User.find params[:user_id]
  end

  def location_after_save
    admin_user_logos_path(@user)
  end

  def permitted_resource_params
    params.require(:logo).permit(:user_id, :logo_file)
  end

  def set_custom
    @logo.custom = true
  end
end
