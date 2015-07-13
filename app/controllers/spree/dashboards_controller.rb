# This controller is to replace the current _eval'ed users controller
# from spree. The spree controller is routed via /account.
#
# This controller *may* provide support for the dashboard tabs.
# The tabs *should* (eventually) make API calls to get it's own data.
# There is a risk that this will become heavy quickly.
class Spree::DashboardsController < Spree::StoreController
  def index
    @favorites = Spree::Favorite.where(buyer: current_spree_user)
      .includes(:product)

    @user = spree_current_user
  end
end
