module Spree::QuoteCalculatorFixedShipping
  def apply_fixed_price_shipping
    log('Using fixed price shipping')
    if product.carton.per_item
      log("Fixed price per item #{product.carton.fixed_price}")
      self.shipping_cost = product.carton.fixed_price * quantity
      self.shipping_option = :fixed_price_per_item
    else
      log("Fixed price total #{product.carton.fixed_price}")
      self.shipping_cost = product.carton.fixed_price
      self.shipping_option = :fixed_price_total
    end

    self.shipping_days = 5
    log("Shipping days #{shipping_days}")
    log("Estimated delivery date (if shipped today) #{Time.zone.now + shipping_days.days}")
    log("Shipping cost #{shipping_cost}")
    log("Selected Shipping option #{shipping_option}")

    self.unit_price += (shipping_cost / quantity)
    log("After applying fixed shipping cost #{self.unit_price}")
  end
end
