module CreatePrebids
  @queue = :prebids

  def self.perform(auction)
    Rails.logger.info "Prebid Job: prebid task running: #{auction}"
    auction = Spree::Auction.find(auction['auction_id'])
    # auction = Spree::Auction.find(auction[:auction_id])
    prebids = Spree::Prebid.where(supplier_id: auction.product.supplier_id)
    prebids.each do |p|
      Rails.logger.info "Prebid Job: requesting bid creation: #{p.id}"
      p.create_prebid(auction.id)
    end
  end
end
