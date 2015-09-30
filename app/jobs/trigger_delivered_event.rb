module TriggerDeliveredEvent
  @queue = :trigger_delivered_event

  def self.perform
    auctions = Spree::Auction.where(state: 'send_for_delivery')
    auctions.each do |auction|
      auction.delivered! if auction.product_delivered?
    end
  end
end