Spree::UsersController.class_eval do
  before_action :load_auctions, only: :show

  def load_auctions
    @auctions = Spree::Auction.where(buyer: current_spree_user)
  end
end
