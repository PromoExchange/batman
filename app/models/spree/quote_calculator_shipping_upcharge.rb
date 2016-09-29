module Spree::QuoteCalculatorShippingUpcharge
  def apply_shipping_upcharge
    carton = product.carton

    raise 'Shipping carton is not active' unless carton.active?

    return if carton.upcharge.nil?

    log('Applying shipping upcharge')

    number_of_cartons = (quantity / carton.quantity.to_f).ceil

    total_upcharge = number_of_cartons * carton.upcharge

    log("Number of cartons #{number_of_cartons}")
    log("Per carton upcharge #{carton.upcharge}")
    log("Total shipping upcharge (#{total_upcharge})")
    log("Pet unit shipping upcharge (#{(total_upcharge / quantity)})")

    self.unit_price += (total_upcharge / quantity)

    log("After applying shipping upcharge #{self.unit_price}")
  end
end
