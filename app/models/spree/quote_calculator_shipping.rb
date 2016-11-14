module Spree::QuoteCalculatorShipping
  include QuoteCalculatorFixedShipping
  include QuoteCalculatorShippingUpcharge

  def apply_shipping_cost
    carton = product.carton
    log("Carton: #{carton}")

    raise 'Shipping carton is not active' unless carton.active?

    # @see Spree::QuoteCalculatorFixedShipping
    return apply_fixed_price_shipping unless product.carton.fixed_price.nil?

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

    if response.message != 'Success'
      log('ERROR: Failed to get UPS shipping rates')
      self.error_code = :shipping_calculation_error
      return nil
    end

    service_code_rate_map = {
      ups_ground: '03',
      ups_3day_select: '12',
      ups_second_day_air: '02',
      ups_next_day_air_saver: '13',
      ups_next_day_air: '01',
      ups_next_day_air_early_am: '14'
    }.freeze

    rate = response.rates.find { |r| r.service_code == service_code_rate_map[shipping_option.to_sym] }

    delivery_date = rate.delivery_date
    if delivery_date.nil?
      delivery_date = response.rates.find do |r|
        r.service_code == service_code_rate_map[:ups_3day_select]
      end.delivery_date + 2.days
    end

    self.shipping_days = ((delivery_date.to_f - Time.zone.now.to_f) / 1.day.to_i).ceil
    log("Shipping days #{shipping_days}")

    log("Estimated delivery date (if shipped today) #{delivery_date}")

    self.shipping_cost = (rate.total_price * number_of_packages.to_f) / 100
    log("Shipping cost #{shipping_cost}")

    log("Selected Shipping option #{shipping_option}")

    self.unit_price += (shipping_cost / quantity)
    log("After applying shipping cost #{self.unit_price}")
  rescue => e
    log("ERROR: (calculate shipping): #{e}")
    0.0
  end
end
