module Preconfigure
  extend ActiveSupport::Concern

  def preconfigure_auction(company_store)
    Rails.logger.debug "CSTORE: Preconfigure called for [#{master.sku}]"

    custom_auction = Spree::Auction.find_by(product: self, state: :custom_auction)

    if custom_auction.present?
      Rails.logger.debug "CSTORE: Custom auction already present [#{master.sku}]"
      return
    end

    Rails.logger.debug "CSTORE: Creating custom auction for #{master.sku}"

    preconfigure_data = Spree::Preconfigure.find_by(product: self)
    auction = Spree::Auction.new(
      product_id: id,
      buyer: company_store.buyer,
      quantity: maximum_quantity,
      imprint_method: preconfigure_data.imprint_method,
      main_color: preconfigure_data.main_color,
      ship_to_zip: supplier.shipping_address.zipcode,
      custom_pms_colors: preconfigure_data.custom_pms_colors,
      logo: preconfigure_data.logo,
      started: Time.zone.now
    )

    auction.save!
    auction.custom_auction
  rescue => e
    Rails.logger.error "CSTORE: Failed to preconfigure product [#{master.sku}] - #{e.message}"
  end
end
