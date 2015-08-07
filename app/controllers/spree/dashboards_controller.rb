class Spree::DashboardsController < Spree::StoreController
  before_action :require_login
  def index
    @favorites = Spree::Favorite.where(buyer: current_spree_user)
      .includes(:product)

    @logo = Spree::Logo.new
    @user = spree_current_user
    @pxaccount = Spree::Pxaccount.new(@user)
  end

  private

  def require_login
    redirect_to login_url unless current_spree_user
  end
end
