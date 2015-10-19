class Spree::Api::TestersController < Spree::Api::BaseController
  def memory_load
    @auctions = Spree::Auction.search(buyer_id_eq: 9)
      .result(distinct: true)
      .includes(:invited_sellers, :review, :bids)
    render 'spree/api/auctions/index'
  end
end
