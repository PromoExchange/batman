class Spree::DashboardsController < Spree::StoreController
  before_action :banned?
  before_action :require_login

  def index
    @logo = Spree::Logo.new
    @user = spree_current_user
    @tab = params[:tab]

    return unless spree_current_user.has_spree_role?(:seller)
  end

  private

  def require_login
    redirect_to login_url unless current_spree_user
  end

  def banned?
    return if spree_current_user.nil?
    return unless spree_current_user.banned?
    sign_out spree_current_user
    flash[:error] = 'This account has been suspended....'
    root_path
  end
end
