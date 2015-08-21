class Spree::Prebid < Spree::Base
  belongs_to :seller, class_name: 'User'
  belongs_to :product
  has_many :adjustments
  has_many :bids

  validates :seller_id, presence: true
  validates :product_id, presence: true

  def create_prebid(auction_id)
    Rails.logger.info 'Prebid: creating prebid'

    auction = Spree::Auction.find(auction_id)

    return if auction.bids.where(prebid_id: id).present?

    return if auction.quantity > (auction.product.maximum_quantity * 2)

    # Get Base price from Volume pricing
    base_unit_price = auction.product_unit_price
    running_unit_price = base_unit_price

    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - product_name=#{auction.product.name}")
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - base_unit_price=#{base_unit_price}")
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - quantity=#{auction.quantity}")

    # Apply discount to base price
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - Vitronic hack, all prices have C discount code")
    running_unit_price = Spree::Price.discount_price('C', base_unit_price)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    # Run cost added to unit price
    # Supplier level
    supplier_upcharges = Spree::UpchargeSupplier.where(related_id: 1)
      .includes(:upcharge_type)
      .pluck(
        'spree_upcharge_types.id',
        'spree_upcharge_types.name',
        :price_code,
        :value
      )

    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - supplier_upcharges.count=#{supplier_upcharges.count}")

    supplier_upcharges.each do |s|
      supplier_upcharge_value = 0.0
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - supplier_upcharges.value=#{s[1]}")
      case s[1]
      when 'pms_color_match'
        Rails.logger.debug(
          "PREBID - A:#{auction_id} P:#{id} - pms_color_match, auction.pms_color_match=#{auction.pms_color_match}"
        )
        if auction.pms_color_match?
          "PREBID - A:#{auction_id} P:#{id} - pms_color_match, auction.pms_color_match=#{auction.pms_color_match}"
          supplier_upcharge_value = Spree::Price.discount_price(s[2], s[3].to_f)
        end
      when 'ink_change'
        Rails.logger.debug(
          "PREBID - A:#{auction_id} P:#{id} - ink_change, auction.change_ink=#{auction.change_ink}"
        )
        if auction.change_ink?
          supplier_upcharge_value = Spree::Price.discount_price(s[2], s[3].to_f)
        end
      when 'no_under_over'
        Rails.logger.debug(
          "PREBID - A:#{auction_id} P:#{id} - no_under_over, auction.no_under_over=#{auction.no_under_over}"
        )
        if auction.no_under_over?
          supplier_upcharge_value = Spree::Price.discount_price(s[2], s[3].to_f)
        end
      else
        Rails.logger.error("PREBID - A:#{auction_id} P:#{id} - Error, unknown supplier upcharge=#{s[1]}")
      end

      if supplier_upcharge_value > 0.0
        Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - upcharge_code=#{s[2]}")
        Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - upcharge_value=#{s[3].to_f}")
        running_unit_price += (supplier_upcharge_value / auction.quantity)
        Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")
      else
        Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - Supplier upcharge not applied")
      end
    end

    # Product level
    product_upcharges = Spree::UpchargeProduct.where(
      related_id: auction.product.id,
      imprint_method_id: auction.imprint_method_id
    ).includes(:upcharge_type)
      .pluck(
        'spree_upcharge_types.id',
        'spree_upcharge_types.name',
        :actual,
        :price_code,
        :value
      )

    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - product_run_charge_count=#{product_upcharges.count}")

    # Decoration cost added to unit price
    # PMS Color match added to unit price
    # Setup cost added to unit price
    product_upcharges.each do |c|
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - upcharge=#{c[2]}")

      upcharge_value = c[4].to_f
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - upcharge_value=#{upcharge_value}")

      # TODO: parse price code string for ranges
      discounted_upcharge_value = Spree::Price.discount_price('G', c[4].to_f)
      per_unit_product_run_charge = discounted_upcharge_value / auction.quantity

      Rails.logger.debug(
        "PREBID - A:#{auction_id} P:#{id} - per_unit_product_run_charge=#{per_unit_product_run_charge}")

      running_unit_price += per_unit_product_run_charge
      Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")
    end
    # Additional costs added to unit price

    # Apply tax from raxrate table
    tax_rate = 0.0
    unless auction.buyer.ship_address.nil?
      buyers_state_id = auction.buyer.ship_address.state_id
      Rails.logger.debug(
        "PREBID - A:#{auction_id} P:#{id} - buyers shipping state =#{auction.buyer.ship_address.state.name}")

      tax_zone_id = Spree::ZoneMember
        .where(zoneable_id: buyers_state_id)
        .includes(:zone)
        .pluck('spree_zones.id').first

      tax_rate_record = Spree::TaxRate.where(user_id: seller_id, zone_id: tax_zone_id).first

      tax_rate = tax_rate_record.amount.to_f unless tax_rate_record.nil?
    end
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - tax_rate=#{tax_rate}")
    running_unit_price /= (1 - tax_rate)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    # Shipping based on buyers zip
    # Package needs weight, height, width and depth
    shipping_cost = calculate_shipping auction
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - shipping_cost=#{shipping_cost}")
    running_unit_price += (shipping_cost / auction.quantity)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    # Seller markup
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - markup=#{markup.to_f}")
    running_unit_price *= (1 + markup.to_f)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    # Promo exchange commission
    px_commission = 0.0499
    px_commission = 0.0299 if auction.preferred?(seller)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - auction.preferred?(seller)=#{auction.preferred?(seller)}")
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - px_commission=#{px_commission}")
    running_unit_price /= (1 - px_commission)
    Rails.logger.debug("PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}")

    # Payment processing cost
    if auction.payment_method == 'Check'
      payment_processing_commission = 0.0
    else
      payment_processing_commission = 0.029
    end
    payment_processing_flat_fee = 0.30

    Rails.logger.debug(
      "PREBID - A:#{auction_id} P:#{id} - payment_processing_commission=#{payment_processing_commission}"
    )
    running_unit_price /= (1 - payment_processing_commission)
    Rails.logger.debug(
      "PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}"
    )

    Rails.logger.debug(
      "PREBID - A:#{auction_id} P:#{id} - payment_processing_flat_fee=#{payment_processing_flat_fee}"
    )
    running_unit_price += (payment_processing_flat_fee / auction.quantity)
    Rails.logger.debug(
      "PREBID - A:#{auction_id} P:#{id} - running_unit_price=#{running_unit_price}"
    )

    Spree::Bid.transaction do
      bid = Spree::Bid.create(
        seller_id: seller_id,
        auction_id: auction.id,
        prebid_id: id
      )

      li = Spree::LineItem.create(
        currency: 'USD',
        order_id: bid.order.id,
        quantity: bid.auction.quantity,
        variant: bid.auction.product.master
      )

      li.price = running_unit_price
      li.save!

      order_updater = Spree::OrderUpdater.new(bid.order)
      order_updater.update

      bid.save
    end
  end

  def calculate_shipping(auction)
    shipping_weight_id = Spree::Property.where(name: 'shipping_weight').first.id
    shipping_dimensions_id = Spree::Property.where(name: 'shipping_dimensions').first.id
    shipping_quantity_id = Spree::Property.where(name: 'shipping_quantity').first.id

    property = auction.product.product_properties.where(property_id: shipping_weight_id).first
    fail 'Shipping weight is nil' if property.nil?
    shipping_weight = property.value

    property = auction.product.product_properties.where(property_id: shipping_dimensions_id).first
    fail 'Shipping dimensions is nil' if property.nil?
    shipping_dimensions = property.value

    property = auction.product.product_properties.where(property_id: shipping_quantity_id).first
    fail 'Shipping quantity is nil' if property.nil?
    shipping_quantity = property.value

    Rails.logger.debug("PREBID - A:#{auction.id} P:#{id} - shipping_weight=#{shipping_weight}")
    Rails.logger.debug("PREBID - A:#{auction.id} P:#{id} - shipping_dimensions=#{shipping_dimensions}")
    Rails.logger.debug("PREBID - A:#{auction.id} P:#{id} - shipping_quantity=#{shipping_quantity}")

    number_of_packages = (auction.quantity / shipping_quantity.to_f).ceil

    Rails.logger.debug("PREBID - A:#{auction.id} P:#{id} - number_of_packages=#{number_of_packages}")

    dimensions = shipping_dimensions.gsub(/[A-Z]/, '').gsub(/ /, '').split('x')
    package = ActiveShipping::Package.new(
      shipping_weight.to_i * 16,
      dimensions.map(&:to_i),
      units: :imperial
    )

    Rails.logger.debug("PREBID - A:#{auction.id} P:#{id} - shipping_origin zipcode=#{seller.shipping_address.zipcode}")

    origin = ActiveShipping::Location.new(
      country: seller.shipping_address.country.iso,
      state: seller.shipping_address.state.abbr,
      city: seller.shipping_address.city,
      zip: seller.shipping_address.zipcode
    )

    Rails.logger.debug(
      "PREBID - A:#{auction.id} P:#{id} - shipping_destination zipcode=#{auction.buyer.shipping_address.zipcode}"
    )

    destination = ActiveShipping::Location.new(
      country: auction.buyer.shipping_address.country.iso,
      state: auction.buyer.shipping_address.state.abbr,
      city: auction.buyer.shipping_address.city,
      zip: auction.buyer.shipping_address.zipcode
    )

    ups = ActiveShipping::UPS.new(
      login: ENV['UPS_API_USERID'],
      password: ENV['UPS_API_PASSWORD'],
      key: ENV['UPS_API_KEY']
    )
    response = ups.find_rates(origin, destination, package)

    ups_rates = response.rates.sort_by(&:price).collect { |rate| [rate.service_name, rate.price] }

    (ups_rates[0][1] * number_of_packages.to_f) / 100
  rescue => e
    Rails.logger.error("PREBID - A:#{auction.id} P:#{id} - Failed to calculate shipping")
    Rails.logger.error("PREBID - A:#{auction.id} P:#{id} - #{e.message}")
    0.0
  end
end
