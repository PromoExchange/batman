module SendTrackingInfo
  @queue = :send_tracking_info

  def self.perform(auction_id)
    @auction = Spree::Auction.find(auction_id)
    BuyerMailer.tracking_info(@auction).deliver
  end
end
