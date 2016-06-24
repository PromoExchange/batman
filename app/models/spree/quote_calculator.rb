module Spree::QuoteCalculator
  def apply_price_discount
    self.unit_price =
      Spree::Price.discount_price(product.price_code(quantity), product.unit_price(quantity))
  end
end
