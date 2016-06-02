module CreatePrebids
  @queue = :prebids

  def self.perform(auction)
    Rails.logger.info "Prebid Job: prebid task running: #{auction}"
    auction = Spree::Auction.find(auction['auction_id'])

    supplier_id = auction.product.original_supplier_id if auction.clone_id.present?
    supplier_id ||= auction.product.supplier_id

    prebids = Spree::Prebid.where(supplier_id: supplier_id)
    prebids.each do |p|
      Rails.logger.info "Prebid Job: requesting bid creation: #{p.id}"
      p.create_prebid(auction.id, Spree::ShippingOption::OPTION[:ups_ground].to_s)
    end
  end
end
