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

    # Do not create a duplicate prebid
    return if auction.bids.where(prebid_id: id).present?

    # Do not prebid if the Quantity > 2 * EQP
    return if auction.quantity > (auction.product.maximum_quantity * 2)

    # Cannot prebid if no shipping/packaging data
    return unless auction.product.prebid_ability!

    # (TEMP) Do not prebid if this seller is not preferred
    # return unless auction.preferred?(seller)

    # No prebids from banned users
    return if seller.banned?

    auction_data = {
      auction_id: auction_id,
      prebid_id: id,
      base_unit_price: auction.product_unit_price,
      running_unit_price: auction.product_unit_price,
      quantity: auction.quantity,
      num_locations: auction.num_locations,
      num_colors: auction.num_colors,
      rush: auction.rush?
    }

    log_debug(auction_data, "product_name=#{auction.product.name}")
    log_debug(auction_data, "base_unit_price=#{auction_data[:base_unit_price]}")
    log_debug(auction_data, "quantity=#{auction_data[:quantity]}")

    # Apply discount to base price
    log_debug(auction_data, 'Vitronic hack, all prices have C discount code')
    apply_price_discount(auction_data, 'C')

    # Supplier level
    auction_data[:supplier_upcharges] = Spree::UpchargeSupplier.where(related_id: 1)
      .includes(:upcharge_type)
      .pluck(
        'spree_upcharge_types.id',
        'spree_upcharge_types.name',
        :price_code,
        :value
      )

    log_debug(auction_data, "auction_data[:supplier_upcharges].count=#{auction_data[:supplier_upcharges].count}")
    auction_data[:flags] = {
      pms_color_match: auction.pms_color_match,
      change_ink: auction.change_ink,
      no_under_over: auction.no_under_over
    }
    apply_supplier_upcharges(auction_data)

    # Product level
    auction_data[:product_upcharges] = Spree::UpchargeProduct.where(
      related_id: auction.product.id,
      imprint_method_id: auction.imprint_method_id
    ).includes(:upcharge_type)
      .order(:position)
      .pluck(
        'spree_upcharge_types.id',
        'spree_upcharge_types.name',
        :actual,
        :price_code,
        :value,
        :range
      )

    log_debug(auction_data, "product_run_charge_count=#{auction_data[:product_upcharges].count}")
    apply_product_upcharges(auction_data)

    # Decoration cost added to unit price
    # PMS Color match added to unit price
    # Setup cost added to unit price
    # Additional costs added to unit price

    # Apply tax from raxrate table
    tax_rate = 0.0
    unless auction.shipping_address_id.nil?
      buyers_state_id = auction.shipping_address.state_id
      log_debug(auction_data, "buyers shipping state =#{auction.buyer.ship_address.state.name}")

      tax_zone_id = Spree::ZoneMember
        .where(zoneable_id: buyers_state_id)
        .includes(:zone)
        .pluck('spree_zones.id').first

      tax_rate_record = Spree::TaxRate.find_by(user_id: seller_id, zone_id: tax_zone_id)

      tax_rate = tax_rate_record.amount.to_f unless tax_rate_record.nil?
    end
    log_debug(auction_data, "tax_rate=#{tax_rate}")
    auction_data[:running_unit_price] /= (1 - tax_rate)
    log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")

    # Shipping based on buyers zip
    # Package needs weight, height, width and depth
    shipping_cost = calculate_shipping auction
    log_debug(auction_data, "shipping_cost=#{shipping_cost}")
    auction_data[:running_unit_price] += (shipping_cost / auction_data[:quantity])
    log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")

    # Seller markup
    log_debug(auction_data, "markup=#{markup.to_f}")
    auction_data[:running_unit_price] *= (1 + markup.to_f)
    log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")

    # Promo exchange commission
    px_commission = 0.0899
    px_commission = 0.0399 if auction.preferred?(seller)
    log_debug(auction_data, "auction.preferred?(seller)=#{auction.preferred?(seller)}")
    log_debug(auction_data, "px_commission=#{px_commission}")
    auction_data[:running_unit_price] /= (1 - px_commission)
    log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")

    # Payment processing cost
    apply_processing_fee(auction, auction_data)

    Spree::Bid.transaction do
      bid = Spree::Bid.create(
        seller_id: seller_id,
        auction_id: auction.id,
        prebid_id: id
      )

      li = Spree::LineItem.create(
        currency: 'USD',
        order_id: bid.order.id,
        quantity: 1,
        variant: bid.auction.product.master
      )

      li.price = auction_data[:running_unit_price] * auction.quantity
      li.save!

      order_updater = Spree::OrderUpdater.new(bid.order)
      order_updater.update

      bid.save!
    end
  end

  private

  def apply_processing_fee(auction, auction_data)
    if auction.preferred?(seller)
      log_debug(auction_data, 'Skipping processing fee for preferred seller')
      return
    end

    if auction.payment_method == 'Check'
      payment_processing_commission = 0.0
    else
      payment_processing_commission = 0.029
    end
    payment_processing_flat_fee = 0.30

    log_debug(auction_data, "payment_processing_commission=#{payment_processing_commission}")
    auction_data[:running_unit_price] /= (1 - payment_processing_commission)
    log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")

    log_debug(auction_data, "payment_processing_flat_fee=#{payment_processing_flat_fee}")
    auction_data[:running_unit_price] += (payment_processing_flat_fee / auction.quantity)
    log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")
  end

  def log_format(auction_data, level, message)
    "PREBID #{level} A:#{auction_data[:auction_id]} P:#{auction_data[:prebid_id]} - #{message}"
  end

  def log_error(auction_data, message)
    Rails.logger.error(log_format(auction_data, 'ERROR', message))
  end

  def log_debug(auction_data, message)
    Rails.logger.debug(log_format(auction_data, 'DEBUG', message))
  end

  def apply_price_discount(auction_data, discount_code)
    auction_data[:running_unit_price] = Spree::Price.discount_price(discount_code, auction_data[:base_unit_price])
    log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")
  end

  def apply_supplier_upcharges(auction_data)
    auction_data[:supplier_upcharges].each do |supplier_upcharge|
      supplier_upcharge_value = 0.0
      log_debug(auction_data, "supplier_upcharges.value=#{supplier_upcharge[1]}")

      # [0] = spree_upcharge_types.id
      # [1] = spree_upcharge_types.name
      # [2] = price_code,
      # [3] = value
      case supplier_upcharge[1]
      when 'pms_color_match'
        log_debug(auction_data, "[:flags][:pms_color_match]=#{auction_data[:flags][:pms_color_match]}")
        if auction_data[:flags][:pms_color_match] == true
          supplier_upcharge_value = Spree::Price.discount_price(supplier_upcharge[2], supplier_upcharge[3].to_f)
        end
      when 'ink_change'
        log_debug(auction_data, "[:flags][:change_ink]=#{auction_data[:flags][:change_ink]}")
        if auction_data[:flags][:change_ink] == true
          supplier_upcharge_value = Spree::Price.discount_price(supplier_upcharge[2], supplier_upcharge[3].to_f)
        end
      when 'no_under_over'
        log_debug(auction_data, "auction_data[:flags][:no_under_over]=#{auction_data[:flags][:no_under_over]}")
        if auction_data[:flags][:no_under_over] == true
          supplier_upcharge_value = Spree::Price.discount_price(supplier_upcharge[2], supplier_upcharge[3].to_f)
        end
      else
        log_error(auction_data, "unknown supplier id = #{supplier_upcharge[0]}, upcharge=#{supplier_upcharge[1]}")
      end

      if supplier_upcharge_value > 0.0
        log_debug(auction_data, "upcharge_code=#{supplier_upcharge[2]}")
        log_debug(auction_data, "upcharge_value=#{supplier_upcharge[3].to_f}")
        auction_data[:running_unit_price] += (supplier_upcharge_value / auction_data[:quantity])
        log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")
      else
        log_debug(auction_data, 'Supplier upcharge not applied')
      end
    end
  end

  def apply_product_upcharges(auction_data)
    auction_data[:product_upcharges].each do |product_upcharge|
      # [0] = 'spree_upcharge_types.id',
      # [1] = 'spree_upcharge_types.name',
      # [2] = :actual,
      # [3] = :price_code,
      # [4] = :value
      # [5] = :range
      log_debug(auction_data, "upcharge=#{product_upcharge[2]}")

      upcharge_value = product_upcharge[4].to_f
      log_debug(auction_data, "upcharge_value=#{upcharge_value}")

      price_code = product_upcharge[3].gsub(/[1-9]/, '')

      in_range = false
      unless product_upcharge[5].nil?
        bounds = []
        # Is it open ended
        if product_upcharge[5].include? '+'
          bounds[0] = product_upcharge[5].gsub(/\+/, '').to_i
          bounds[1] = bounds[0] * 2
        else
          bounds = product_upcharge[5].gsub(/[()]/, '').split('..').map(&:to_i)
        end
        range = Range.new(bounds[0], bounds[1])
        in_range = range.member?(auction_data[:quantity])
      end

      log_debug(auction_data, "range=#{product_upcharge[5]}")
      log_debug(auction_data, "in_range=#{in_range}")
      log_debug(auction_data, "product_upcharge[1]=#{product_upcharge[1]}")

      case product_upcharge[1]
      when 'setup'
        # No ranges
        setup_charge = product_upcharge[4].to_f
        log_debug(auction_data, "setup upcharge #{setup_charge}")
        log_debug(auction_data, "setup upcharge discount #{price_code}")
        auction_data[:running_unit_price] += (
          (Spree::Price.discount_price(price_code, setup_charge) * auction_data[:num_colors]) / auction_data[:quantity]
        )
        log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")
      when 'run'
        next unless in_range
        run_charge = product_upcharge[4].to_f
        log_debug(auction_data, "run upcharge #{run_charge}")
        log_debug(auction_data, "run upcharge discount #{price_code}")
        auction_data[:running_unit_price] += (
          Spree::Price.discount_price(price_code, run_charge)
        )
        log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")
      when 'additional_location_run'
        next unless in_range
        if auction_data[:num_locations] > 1
          additional_location_charge = product_upcharge[4].to_f
          log_debug(auction_data, "additional location upcharge #{additional_location_charge}")
          log_debug(auction_data, "additional location upcharge discount #{price_code}")
          auction_data[:running_unit_price] += (
            Spree::Price.discount_price(price_code, additional_location_charge)
          )
          log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")
        end
      when 'second_color_run', 'additional_color_run', 'multiple_color_run'
        next unless in_range
        log_debug(auction_data, "auction_data[:num_colors]=#{auction_data[:num_colors]}")
        if auction_data[:num_colors] > 1
          multiple_colors_charge = product_upcharge[4].to_f
          log_debug(auction_data, "multiple colors upcharge #{multiple_colors_charge}")
          log_debug(auction_data, "multiple colors upcharge discount #{price_code}")
          auction_data[:running_unit_price] += (
            Spree::Price.discount_price(price_code, multiple_colors_charge)
          )
          log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")
        end
      when 'rush'
        # No ranges
        rush_charge = product_upcharge[4].to_f
        log_debug(auction_data, "rush upcharge #{rush_charge}")
        log_debug(auction_data, "rush upcharge discount #{price_code}")
        auction_data[:running_unit_price] += (
          Spree::Price.discount_price(price_code, rush_charge) / auction_data[:quantity]
        )
        log_debug(auction_data, "running_unit_price=#{auction_data[:running_unit_price]}")
      end
    end
  end

  def calculate_shipping(auction)
    shipping_weight_id = Spree::Property.where(name: 'shipping_weight').first.id
    shipping_dimensions_id = Spree::Property.where(name: 'shipping_dimensions').first.id
    shipping_quantity_id = Spree::Property.where(name: 'shipping_quantity').first.id

    property = auction.product.product_properties.find_by(property_id: shipping_weight_id)
    fail 'Shipping weight is nil' if property.nil?
    shipping_weight = property.value

    property = auction.product.product_properties.find_by(property_id: shipping_dimensions_id)
    fail 'Shipping dimensions is nil' if property.nil?
    shipping_dimensions = property.value

    property = auction.product.product_properties.find_by(property_id: shipping_quantity_id)
    fail 'Shipping quantity is nil' if property.nil?
    shipping_quantity = property.value

    Rails.logger.debug("PREBID DEBUG A:#{auction.id} P:#{id} - shipping_weight=#{shipping_weight}")
    Rails.logger.debug("PREBID DEBUG A:#{auction.id} P:#{id} - shipping_dimensions=#{shipping_dimensions}")
    Rails.logger.debug("PREBID DEBUG A:#{auction.id} P:#{id} - shipping_quantity=#{shipping_quantity}")

    number_of_packages = (auction.quantity / shipping_quantity.to_f).ceil

    Rails.logger.debug("PREBID DEBUG A:#{auction.id} P:#{id} - number_of_packages=#{number_of_packages}")

    dimensions = shipping_dimensions.gsub(/[A-Z]/, '').delete(' ').split('x')
    package = ActiveShipping::Package.new(
      shipping_weight.to_i * 16,
      dimensions.map(&:to_i),
      units: :imperial
    )

    Rails.logger.debug("PREBID DEBUG A:#{auction.id} P:#{id} - shipping_origin zipcode=#{seller.shipping_address.zipcode}")

    origin = ActiveShipping::Location.new(
      country: seller.shipping_address.country.iso,
      state: seller.shipping_address.state.abbr,
      city: seller.shipping_address.city,
      zip: seller.shipping_address.zipcode
    )

    Rails.logger.debug(
      "PREBID DEBUG A:#{auction.id} P:#{id} - shipping_destination zipcode=#{auction.shipping_address.zipcode}"
    )

    destination = ActiveShipping::Location.new(
      country: auction.shipping_address.country.iso,
      state: auction.shipping_address.state.abbr,
      city: auction.shipping_address.city,
      zip: auction.shipping_address.zipcode
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
    Rails.logger.error("PREBID ERROR A:#{auction.id} P:#{id} - Failed to calculate shipping")
    Rails.logger.error("PREBID ERROR A:#{auction.id} P:#{id} - #{e.message}")
    0.0
  end
end
