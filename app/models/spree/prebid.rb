class Spree::Prebid < Spree::Base
  belongs_to :seller, class_name: 'User'
  belongs_to :supplier
  has_many :adjustments
  has_many :bids

  validates :seller_id, presence: true
  validates :supplier_id, presence: true

  # TODO: Move this out an SERIOUSLY refactor.
  def create_prebid(options = {})
    options.reverse_merge!(save_bid: true)

    [
      :auction_id,
      :selected_shipping
    ].each do |o|
      raise "Cannot created prebid, missing required option [#{o}]" unless options.key?(o)
    end

    Rails.logger.info 'Prebid: creating prebid'

    auction = Spree::Auction.find(options[:auction_id])

    # Do not prebid if the Quantity > 2 * EQP
    return if auction.quantity > (auction.product.maximum_quantity * 2)

    # Cannot prebid if no shipping/packaging data
    return unless auction.product.prebid_ability?

    # No prebids from banned users
    return if seller.banned?

    # TODO: Move out to lib so we can share and use as an async message
    auction_data = {
      auction_id: options[:auction_id],
      prebid_id: id,
      price_code: auction.product_price_code,
      running_unit_price: auction.product_unit_price,
      quantity: auction.quantity,
      num_locations: auction.num_locations,
      num_colors: auction.num_colors,
      rush: auction.rush?,
      preferred: auction.preferred?(seller),
      messages: [],
      carton: auction.product.carton,
      service_name: '',
      shipping_cost: 0.0,
      delivery_date: nil,
      delivery_days: 5,
      ship_to_zip: auction.ship_to_zip,
      used_eqp: false,
      selected_shipping: options[:selected_shipping],
      shipping_options: []
    }

    unit_price = auction.product_unit_price
    auction_data[:price_code] ||= 'V'

    auction_data[:messages] << "Item name: #{auction.product.name}"
    auction_data[:messages] << "Factory: #{auction.product.supplier.name}"
    if auction.product.original_supplier.present?
      auction_data[:messages] << "Original Factory: #{auction.product.original_supplier.name}"
    end
    auction_data[:messages] << "SKU: #{auction.product.master.sku}"

    unless markup.nil?
      if eqp?
        eqp_price = auction.product.eqp_price
        if eqp_price != 0.0
          auction_data[:messages] << 'Using EQP'
          auction_data[:messages] << "EQP Price (base): #{eqp_price}"
          # Discount it with price code first
          auction_data[:messages] << "EQP Price code: #{auction_data[:price_code]}"
          price_codes = Spree::Price.price_code_to_array(auction.product_price_code)
          auction_data[:messages] << "EQP Applicable Price code: #{price_codes.last}"
          eqp_price = Spree::Price.discount_price(price_codes.last, eqp_price)
          auction_data[:messages] << "EQP Discounted Price (price_code): #{eqp_price}"
          discount = eqp_discount
          discount ||= 0.0
          auction_data[:messages] << "EQP Discount: #{discount}"
          discount_eqp_price = eqp_price * (1 - discount)
          auction_data[:messages] << "EQP Price (discounted percentage): #{discount_eqp_price}"
          unit_price = discount_eqp_price
          auction_data[:used_eqp] = true
        else
          auction_data[:messages] << 'Unable to get EQP'
        end
      end
    end

    auction_data[:base_unit_price] = unit_price
    auction_data[:running_unit_price] = unit_price
    auction_data[:messages] << "Seller: #{auction_data[:preferred] ? 'Preferred' : 'Non-preferred'}"
    auction_data[:messages] << "Item Count: #{auction_data[:quantity]}"
    auction_data[:messages] << "Base Unit Price: #{auction_data[:base_unit_price]}"

    # Apply discount to base price
    if auction_data[:used_eqp] == false
      auction_data[:messages] << "MSRP Price Code: #{auction.product_price_code || 'V'}"
      auction_data[:messages] << "Discount percentage: #{Spree::Price.discount_codes[auction_data[:price_code].to_sym]}"
      auction_data[:messages] << "Initial unit cost: #{auction_data[:running_unit_price]}"
      apply_price_discount(auction_data, auction.product_price_code)
      auction_data[:messages] << "Discount unit cost: #{auction_data[:running_unit_price]}"
    else
      auction_data[:messages] << 'Price already EQP adjusted'
    end

    # Supplier level
    auction_data[:supplier_upcharges] = Spree::UpchargeSupplier.where(related_id: supplier_id)
      .includes(:upcharge_type)
      .pluck(
        'spree_upcharge_types.id',
        'spree_upcharge_types.name',
        :price_code,
        :value
      )

    auction_data[:flags] = {
      pms_color_match: auction.pms_color_match,
      change_ink: auction.change_ink,
      no_under_over: auction.no_under_over
    }
    apply_supplier_upcharges(auction_data)
    auction_data[:messages] << "After supplier level: #{auction_data[:running_unit_price]}"
    auction_data[:messages] << "Number of imprint colors: #{auction_data[:num_colors]}"

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

    apply_product_upcharges(auction_data)
    auction_data[:messages] << "After product level upcharges: #{auction_data[:running_unit_price]}"

    # Apply tax from raxrate table
    tax_rate = 0.0
    unless auction.shipping_address_id.nil?
      buyers_state_id = auction.shipping_address.state_id
      tax_zone_id = Spree::ZoneMember
        .where(zoneable_id: buyers_state_id)
        .includes(:zone)
        .pluck('spree_zones.id').first

      tax_rate_record = Spree::TaxRate.find_by(user_id: seller_id, zone_id: tax_zone_id)

      tax_rate = tax_rate_record.amount.to_f unless tax_rate_record.nil?
    end
    auction_data[:messages] << "Applying tax rate #{tax_rate}"
    auction_data[:running_unit_price] /= (1 - tax_rate)
    auction_data[:messages] << "After applying tax rate: #{auction_data[:running_unit_price]}"

    # Shipping based on buyers zip
    # Package needs weight, height, width and depth
    shipping_cost = calculate_shipping(auction_data)

    auction_data[:messages] << "Selected Shipping cost #{shipping_cost}"
    auction_data[:messages] << "Selected Shipping option #{auction_data[:selected_shipping]}"
    auction_data[:messages] << "Selected Shipping method #{auction_data[:service_name]}"
    auction_data[:messages] << "Selected Shipping delivery days #{auction_data[:delivery_days]}"
    auction_data[:running_unit_price] += (shipping_cost / auction_data[:quantity])
    auction_data[:messages] << "After applying shipping cost: #{auction_data[:running_unit_price]}"

    # Seller markup
    seller_markup = markup
    seller_markup || 0.0

    # HACK: For Yeti
    seller_markup = 0.0766103970737429 if auction.product.master.sku == 'PC-YRAM20'

    auction_data[:messages] << "Applying markup: #{seller_markup.to_f}"
    auction_data[:running_unit_price] *= (1 + seller_markup.to_f)
    auction_data[:messages] << "After applying markup: #{auction_data[:running_unit_price]}"

    # Promo exchange commission
    px_commission = 0.0899
    px_commission = 0.0399 if auction_data[:preferred]
    auction_data[:messages] << "Applying PX commission: #{px_commission}"
    auction_data[:running_unit_price] /= (1 - px_commission)
    auction_data[:messages] << "After applying commission: #{auction_data[:running_unit_price]}"

    # Payment processing cost
    auction_data[:messages] << 'Applying processing cost:'
    apply_processing_fee(auction_data)
    auction_data[:messages] << "After applying processing cost: #{auction_data[:running_unit_price]}"

    # TODO: Move out
    if options[:save_bid]
      Spree::Bid.transaction do
        bid = Spree::Bid.create(
          seller_id: seller_id,
          auction_id: auction.id,
          prebid_id: id,
          service_name: auction_data[:service_name],
          shipping_cost: auction_data[:shipping_cost],
          delivery_days: auction_data[:delivery_days]
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

        auction_data[:bid_id] = bid.id
      end
    end

    auction_data[:messages] << "Total prebid bid: #{auction_data[:running_unit_price] * auction.quantity}"
    auction_data[:messages].each do |message|
      log_debug(auction_data, message)
    end
    auction_data
  rescue StandardError => e
    Rails.logger.error("failed to create prebid #{e}")
  end

  private

  def apply_processing_fee(auction_data)
    return if auction_data[:preferred]

    # NOTE: We are charging a flat fee equal to the payment processing fee of a credit card transaction.
    # This is due to us not knowing the payment method at the beginning of an auction. We charge the greater
    # value to compensate if the buyer selects CC. If they select Check, then we still charge the CC fee.
    payment_processing_commission = 0.029
    payment_processing_flat_fee = 0.30

    auction_data[:messages] << "Payment processing commission: #{payment_processing_commission}"
    auction_data[:messages] << "Payment processing flat fee: #{payment_processing_flat_fee}"

    auction_data[:running_unit_price] /= (1 - payment_processing_commission)
    auction_data[:running_unit_price] += (payment_processing_flat_fee / auction_data[:quantity])
  end

  def log_format(auction_data, message)
    "PREBID A:#{auction_data[:auction_id]} P:#{auction_data[:prebid_id]} - #{message}"
  end

  def log_error(auction_data, message)
    Rails.logger.error(log_format(auction_data, message))
  end

  def log_debug(auction_data, message)
    Rails.logger.debug(log_format(auction_data, message))
  end

  def apply_price_discount(auction_data, discount_code)
    auction_data[:running_unit_price] = Spree::Price.discount_price(discount_code, auction_data[:base_unit_price])
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
        auction_data[:messages] << 'Applying PMS Color match (Supplier):'
        if auction_data[:flags][:pms_color_match] == true
          supplier_upcharge_value = Spree::Price.discount_price(supplier_upcharge[2], supplier_upcharge[3].to_f)
        end
      when 'ink_change'
        auction_data[:messages] << 'Applying Ink Change (Supplier):'
        if auction_data[:flags][:change_ink] == true
          supplier_upcharge_value = Spree::Price.discount_price(supplier_upcharge[2], supplier_upcharge[3].to_f)
        end
      when 'no_under_over'
        auction_data[:messages] << 'Applying No Under and Over (Supplier):'
        if auction_data[:flags][:no_under_over] == true
          supplier_upcharge_value = Spree::Price.discount_price(supplier_upcharge[2], supplier_upcharge[3].to_f)
        end
      else
        log_error(auction_data, "unknown supplier id = #{supplier_upcharge[0]}, upcharge=#{supplier_upcharge[1]}")
      end

      next if supplier_upcharge_value <= 0.0

      auction_data[:messages] << "Supplier Upcharge Cost: #{supplier_upcharge[3].to_f}"
      auction_data[:messages] << "Supplier Upcharge Price code: #{supplier_upcharge[2]}"
      auction_data[:messages] << "Supplier Upcharge Discount cost: #{supplier_upcharge_value}"
      auction_data[:running_unit_price] += (supplier_upcharge_value / auction_data[:quantity])
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

      price_code = product_upcharge[3].gsub(/[1-9]/, '')

      in_range = false
      unless product_upcharge[5].blank?
        in_range = false
        if product_upcharge[5].include? '+'
          # It is open ended i.e. 100+ will match quantities > 100
          in_range = (auction_data[:quantity] > product_upcharge[5].gsub(/([()])|\+/, '').to_i)
        else
          # It is closed range i.e. (100..200) which match quantities between 100 and 200
          bounds = product_upcharge[5].gsub(/[()]/, '').split('..').map(&:to_i)
          range = Range.new(bounds[0], bounds[1])
          in_range = range.member?(auction_data[:quantity])
        end
      end

      case product_upcharge[1]
      when 'less_than_minimum'
        next unless in_range
        less_than_minimum_surcharge = product_upcharge[4].to_f
        auction_data[:running_unit_price] += (
          Spree::Price.discount_price(price_code, less_than_minimum_surcharge) /
            auction_data[:quantity]
        )
        auction_data[:messages] << 'Applying less than minimum surcharge'
        auction_data[:messages] << "Surcharge: #{less_than_minimum_surcharge}"
        auction_data[:messages] << "Price code: #{price_code}"
        auction_data[:messages] << 'Discounted Surcharge: '\
          "#{Spree::Price.discount_price(price_code, less_than_minimum_surcharge)}"
        auction_data[:messages] << "After applying surcharge unit cost: #{auction_data[:running_unit_price]}"
      when 'setup'
        setup_charge = product_upcharge[4].to_f
        num_setups = [auction_data[:num_colors].to_i, 1].max
        (1..num_setups).each do
          auction_data[:running_unit_price] += (
            Spree::Price.discount_price(price_code, setup_charge) /
              auction_data[:quantity]
          )
        end
        auction_data[:messages] << "Applying #{num_setups} setups"
        auction_data[:messages] << "Charge: #{setup_charge}"
        auction_data[:messages] << "Price code: #{price_code}"
        auction_data[:messages] << "Discounted Charge: #{Spree::Price.discount_price(price_code, setup_charge)}"
        auction_data[:messages] << "After applying charge unit cost: #{auction_data[:running_unit_price]}"
      when 'run'
        next unless in_range
        run_charge = product_upcharge[4].to_f
        auction_data[:running_unit_price] += Spree::Price.discount_price(price_code, run_charge)
        auction_data[:messages] << 'Applying run charge'
        auction_data[:messages] << "Charge: #{run_charge}"
        auction_data[:messages] << "Price code: #{price_code}"
        auction_data[:messages] << "Discounted Charge: #{Spree::Price.discount_price(price_code, run_charge)}"
        auction_data[:messages] << "After applying charge unit cost: #{auction_data[:running_unit_price]}"
      when 'additional_location_run'
        next unless in_range
        if auction_data[:num_locations] > 1
          additional_location_charge = product_upcharge[4].to_f
          auction_data[:running_unit_price] += Spree::Price.discount_price(price_code, additional_location_charge)
          auction_data[:messages] << 'Applying additional location charge'
          auction_data[:messages] << "Charge: #{additional_location_charge}"
          auction_data[:messages] << "Price code: #{price_code}"
          discount_price = Spree::Price.discount_price(price_code, additional_location_charge)
          auction_data[:messages] << "Discounted Charge: #{discount_price}"
          auction_data[:messages] << "After Run applied unit cost: #{auction_data[:running_unit_price]}"
        end
      when 'second_color_run', 'additional_color_run', 'multiple_color_run'
        next unless in_range
        if auction_data[:num_colors] > 1
          multiple_colors_charge = product_upcharge[4].to_f
          (2..auction_data[:num_colors].to_i).each do
            auction_data[:running_unit_price] += Spree::Price.discount_price(price_code, multiple_colors_charge)
          end
          auction_data[:messages] << "Applying #{auction_data[:num_colors].to_i - 1} additional color charges"
          auction_data[:messages] << "Charge: #{multiple_colors_charge}"
          auction_data[:messages] << "Price code: #{price_code}"
          discount_price = Spree::Price.discount_price(price_code, multiple_colors_charge)
          auction_data[:messages] << "Discounted Charge: #{discount_price}"
          auction_data[:messages] << "After Run applied unit cost: #{auction_data[:running_unit_price]}"
        end
      when 'rush'
        # No ranges
        rush_charge = product_upcharge[4].to_f
        auction_data[:running_unit_price] += (
          Spree::Price.discount_price(price_code, rush_charge) / auction_data[:quantity]
        )
        auction_data[:messages] << 'Applying Rush charges'
        auction_data[:messages] << "Charge: #{rush_charge}"
        auction_data[:messages] << "Price code: #{price_code}"
        auction_data[:messages] << "Discounted Charge: #{Spree::Price.discount_price(price_code, rush_charge)}"
        auction_data[:messages] << "After Rush applied unit cost: #{auction_data[:running_unit_price]}"
      end
    end
  end

  def calculate_shipping(auction_data)
    carton = auction_data[:carton]

    unless carton.fixed_price.nil?
      auction_data[:messages] << 'Using fixed price shipping'
      if carton.per_item
        auction_data[:messages] << "Fixed price per item #{carton.fixed_price}"
        auction_data[:shipping_cost] = carton.fixed_price * auction_data[:quantity]
      else
        auction_data[:messages] << "Fixed price total #{carton.fixed_price}"
        auction_data[:shipping_cost] = carton.fixed_price
      end
      return auction_data[:shipping_cost]
    end

    raise 'Shipping carton weight is nil' if carton.weight.blank?
    shipping_weight = carton.weight

    raise 'Shipping carton length is nil' if carton.length.blank?
    raise 'Shipping carton width is nil' if carton.width.blank?
    raise 'Shipping carton height is nil' if carton.height.blank?
    shipping_dimensions = carton.to_s

    raise 'Shipping quantity is nil' if carton.quantity <= 0

    auction_data[:messages] << 'Applying shipping'

    shipping_quantity = carton.quantity
    auction_data[:messages] << "Carton quantity: #{shipping_quantity}"

    number_of_packages = (auction_data[:quantity] / shipping_quantity.to_f).ceil
    auction_data[:messages] << "Number of packages: #{number_of_packages}"

    dimensions = shipping_dimensions.gsub(/[A-Z]/, '').delete(' ').split('x')
    package = ActiveShipping::Package.new(
      shipping_weight.to_i * 16,
      dimensions.map(&:to_i),
      units: :imperial
    )

    auction_data[:messages] << "Originating zip: #{carton.originating_zip}"
    origin = ActiveShipping::Location.new(
      country: 'USA',
      zip: carton.originating_zip
    )

    auction_data[:messages] << "Destination zip: #{auction_data[:ship_to_zip]}"

    destination = ActiveShipping::Location.new(
      country: 'USA',
      zip: auction_data[:ship_to_zip]
    )

    ups = ActiveShipping::UPS.new(
      login: ENV['UPS_API_USERID'],
      password: ENV['UPS_API_PASSWORD'],
      key: ENV['UPS_API_KEY']
    )
    response = ups.find_rates(origin, destination, package)
    ups_rates = response.rates.sort_by(&:price).collect { |rate| [rate.service_name, rate.price, rate.delivery_date] }

    shipping_option_map = {
      'UPS Ground' => :ups_ground,
      'UPS Three-Day Select' => :ups_3day_select,
      'UPS Second Day Air' => :ups_second_day_air,
      'UPS Next Day Air Saver' => :ups_next_day_air_saver,
      'UPS Next Day Air Early A.M.' => :ups_next_day_air_early_am,
      'UPS Next Day Air' => :ups_next_day_air
    }.freeze

    shipping_sym = Spree::ShippingOption::OPTION.key(auction_data[:selected_shipping].to_i)

    delivery_date = nil
    ups_rates.each do |rate|
      next if shipping_option_map[rate[0]] != shipping_sym
      auction_data[:shipping_cost] = (rate[1] * number_of_packages.to_f) / 100
      auction_data[:service_name] = rate[0] unless rate[0].blank?
      delivery_date = rate[2]
      break
    end

    if delivery_date.nil?
      auction_data[:service_name] = ups_rates[0][0] unless ups_rates[0][0].blank?
      auction_data[:shipping_cost] = (ups_rates[0][1] * number_of_packages.to_f) / 100
    end

    begin
      delta = 0
      if delivery_date.nil?
        # Try and use the cheapest and adjust
        delivery_date ||= ups_rates[1][2]
        delta = 2
      end
      days_diff = delta + ((delivery_date.to_f - Time.zone.now.to_f) / 86400).ceil
    rescue
      days_diff = 5
    end

    auction_data[:delivery_date] = Time.zone.now + days_diff.days
    auction_data[:delivery_days] = days_diff
    auction_data[:shipping_cost]
  rescue => e
    Rails.logger.error("PREBID ERROR A:#{auction_data[:auction_id]} P:#{id} - failed to calculate shipping")
    Rails.logger.error("PREBID ERROR A:#{auction_data[:auction_id]} P:#{id} - #{e.message}")
    0.0
  end
end
