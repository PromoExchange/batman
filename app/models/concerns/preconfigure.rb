module Preconfigure
  extend ActiveSupport::Concern

  def preconfigure
    logger.warn "CSTORE: Preconfigure called for #{master.sku}"
    # Is there an auction for this product
    custom_auction = Spree::Auction.where(custom: true, product: self).first
    # if custom_auction.nil?
    #   @auction = Spree::Auction.new(
    #     product: self,
    #     buyer_id: auction_data[:buyer_id],
    #     quantity: minimum_quantity,
    #     imprint_method_id: auction_data[:imprint_method_id],
    #     main_color_id: auction_data[:main_color_id],
    #     ship_to_zip: auction_data[:ship_to_zip],
    #     logo_id: auction_data[:logo_id],
    #     custom_pms_colors: auction_data[:custom_pms_colors],
    #     started: Time.zone.now
    #   )
    # end
  end
end
