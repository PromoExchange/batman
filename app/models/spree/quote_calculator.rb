module Spree::QuoteCalculator
  def calculate(options = {})
    [
      :selected_shipping
    ].each do |o|
      raise "Cannot calculate quote, missing required option [#{o}]" unless options.key?(o)
    end

    log('Quote: Calculating')
  end

  def apply_price_discount
    self.unit_price =
      Spree::Price.discount_price(product.price_code(quantity), product.unit_price(quantity))
  end
end
