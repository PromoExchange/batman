module Spree::QuoteCalculatorShipping
  def apply_shipping
    shipping_cost = calculate_shipping

    log("Selected Shipping cost #{shipping_cost}")
    log("Selected Shipping option #{Spree::ShippingOption::OPTION.key(selected_shipping_option)}")
    self.unit_price += (shipping_cost / quantity)
    log("After applying shipping cose: #{self.unit_price}")
  end

  def calculate_shipping
    return calculate_fixed_price unless product.carton.fixed_price.nil?
    carton = product.carton

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
    log("ERROR (calculate shipping): #{e}")
    0.0
  end

  def calculate_fixed_price
    carton = product.carton
    return if carton.fixed_price.nil?
    shipping_cost = 0.0
    log('Using fixed price shipping')
    if carton.per_item
      log("Fixed price per item #{carton.fixed_price}")
      shipping_cost = carton.fixed_price * quantity
    else
      log("Fixed price total #{carton.fixed_price}")
      shipping_cost = carton.fixed_price
    end
    shipping_cost
  end
end
