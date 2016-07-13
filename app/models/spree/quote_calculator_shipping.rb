module Spree::QuoteCalculatorShipping
  def calculate_shipping
    return calculate_fixed_price unless product.carton.fixed_price.nil?
    carton = product.carton
    log("Carton: #{carton}")

    raise 'Shipping carton weight is not active' unless carton.active?
    shipping_weight = carton.weight
    shipping_dimensions = carton.to_s

    raise 'Shipping quantity is nil' if carton.quantity <= 0

    log('Applying shipping')

    shipping_quantity = carton.quantity
    log("Carton quantity: #{shipping_quantity}")

    number_of_packages = (quantity / shipping_quantity.to_f).ceil
    log("Number of packages: #{number_of_packages}")

    dimensions = shipping_dimensions.gsub(/[A-Z]/, '').delete(' ').split('x')
    package = ActiveShipping::Package.new(
      shipping_weight.to_i * 16,
      dimensions.map(&:to_i),
      units: :imperial
    )

    log("Originating zip: #{carton.originating_zip}")
    origin = ActiveShipping::Location.new(
      country: 'USA',
      zip: carton.originating_zip
    )

    log("Destination zip: #{shipping_address.zipcode}")

    destination = ActiveShipping::Location.new(
      country: 'USA',
      zip: shipping_address.zipcode
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

    shipping_options.destroy_all

    shipping_sym = Spree::ShippingOption::OPTION.key(selected_shipping_option)

    shipping_cost = 0.0
    selected_shipping_cost = 0.0
    delivery_date = nil

    ups_rates.each do |rate|
      shipping_cost = (rate[1] * number_of_packages.to_f) / 100
      delivery_date = rate[2]
      service_name = rate[0]

      selected_shipping_cost = shipping_cost if shipping_option_map[rate[0]] == shipping_sym

      begin
        delta = 0
        if delivery_date.nil?
          # UPS Ground does not always have a delivery delivery delivery_date
          # We take the next rate delivery date and add 2
          delivery_date ||= ups_rates[1][2]
          delta = 2
        end
        days_diff = delta + ((delivery_date.to_f - Time.zone.now.to_f) / 86400).ceil
      rescue
        days_diff = 5
      end

      shipping_options.build(
        name: service_name,
        delivery_date: Time.zone.now + days_diff.days,
        delivery_days: days_diff,
        shipping_option: Spree::ShippingOption::OPTION[shipping_option_map[rate[0]]],
        shipping_cost: shipping_cost
      )
    end
    selected_shipping_cost
  rescue => e
    log("ERROR: (calculate shipping): #{e}")
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
