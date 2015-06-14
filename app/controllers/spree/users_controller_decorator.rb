Spree::UsersController.class_eval do
  before_action :load_auctions, only: :show
  before_action :load_favorites, only: :show

  def load_auctions
    @auctions = Spree::Auction.where(buyer: current_spree_user)
  end

  def load_favorites
    @favorites = Spree::Favorite.where(buyer: current_spree_user)
      .includes(:product)
  end
end
