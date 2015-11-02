class Spree::Api::ProductRequestsController < Spree::Api::BaseController
  def index
    @product_requests = Spree::ProductRequest.search(
      buyer_id_eq: current_spree_user.id
    ).result(distinct: true)
    render 'spree/api/product_requests/index'
  end
end
