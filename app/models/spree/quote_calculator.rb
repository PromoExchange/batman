module Spree::QuoteCalculator
  def apply_price_discount(discount_code)
    @fields['running_unit_price'] =
      Spree::Price.discount_price(discount_code, @fields['base_unit_price'])
  end
end
