Spree::TaxonsController.class_eval do
  before_action :require_login

  private

  def require_login
    redirect_to login_url unless current_spree_user
  end
end
