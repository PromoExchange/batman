class Spree::PxtaxRatesController < Spree::StoreController
  before_action :require_login
  before_action :fetch_taxrates

  private

  def require_login
    redirect_to login_url unless current_spree_user
  end

  def fetch_taxrates
    @tax_rates = Spree::TaxRate.where(user: current_spree_user).includes(:zone)
  end

  def pxtaxrate_params
    params.require(:pxtaxrates).permit(
      :id,
      tax_rate: [
        [
          :zoneable_id,
          :rate
        ]
      ]
    )
  end
end
