module ProductDelivered
  @queue = :product_delivered

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    BuyerMailer.product_delivered(@auction).deliver
  end
end