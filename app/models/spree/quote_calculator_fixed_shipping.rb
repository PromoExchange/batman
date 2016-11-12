module Spree::QuoteCalculatorFixedShipping
  def calculate_fixed_price
    shipping_cost = 0.0
    log('Using fixed price shipping')
    if product.carton.per_item
      log("Fixed price per item #{product.carton.fixed_price}")
      shipping_cost = product.carton.fixed_price * quantity
      shipping_option = :fixed_price_per_item
    else
      log("Fixed price total #{product.carton.fixed_price}")
      shipping_cost = product.carton.fixed_price
      shipping_option = :fixed_price_total
    end

    self.shipping_option = shipping_option

    shipping_options.build(
      name: 'Fixed price',
      delivery_date: Time.zone.now + fixed_price_delivery_days.days,
      delivery_days: fixed_price_delivery_days,
      shipping_option: shipping_option,
      shipping_cost: shipping_cost
    )
    shipping_cost
  end
end
