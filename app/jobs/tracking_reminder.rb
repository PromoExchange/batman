module TrackingReminder
  @queue = :tracking_reminder

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.tracking_reminder(@auction).deliver if @auction.in_production?
  end
end
