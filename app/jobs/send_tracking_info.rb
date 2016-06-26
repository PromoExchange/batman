module SendTrackingInfo
  @queue = :send_tracking_info

  def self.perform(params)
    @auction = Spree::Auction.find(params[:auction_id])
    BuyerMailer.tracking_info(@auction).deliver
  end
end
