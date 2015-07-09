# This controller is to replace the current _eval'ed users controller
# from spree. The spree controller is routed via /account.
#
# This controller *may* provide support for the dashboard tabs.
# The tabs *should* (eventually) make API calls to get it's own data.
# There is a risk that this will become heavy quickly.
class Spree::DashboardsController < Spree::StoreController
  def index
    @live_auctions = Spree::Auction.open.where(buyer: current_spree_user)
      .page(params[:page])
      .per(params[:per_page] || Spree::Config[:orders_per_page])

    @waiting_auctions = Spree::Auction.waiting.where(buyer: current_spree_user)
      .page(params[:page])
      .per(params[:per_page] || Spree::Config[:orders_per_page])

    @favorites = Spree::Favorite.where(buyer: current_spree_user)
      .includes(:product)
  end

  private

  def dashboard_params
    params.permit(:page, :per_page)
  end
end
