module Spree::QuoteCalculator
  def calculate(options = {})
    [
      :selected_shipping
    ].each do |o|
      raise "Cannot calculate quote, missing required option [#{o}]" unless options.key?(o)
    end

    log('Quote: Calculating')
    log("Item name: #{auction.product.name}")
    log("Factory: #{auction.product.supplier.name}")
    log("Original Factory: #{auction.product.original_supplier.name}")
    log("SKU: #{auction.product.master.sku}")

    # raise "Unable to find markup if" markup.nil?
    if markup.eqp?
      apply_eqp
    else
      self.unit_price = product.unit_price(quantity)
    end
    log("Unit price: #{unit_price}")

  rescue StandardError => e
    Rails.logger.error(e.to_s)
  end

  def apply_eqp
    return unless markup.eqp?

    eqp_price = product.eqp_price
    log('Using EQP')
    log("EQP Price (base): #{eqp_price}")
    log("EQP Price code: #{product.price_code(quantity)}")

    price_codes = Spree::Price.price_code_to_array(product.price_code)
    log("EQP Applicable Price code: #{price_codes.last}")

    eqp_price = Spree::Price.discount_price(price_codes.last, eqp_price)
    log("EQP Discounted Price (price_code): #{eqp_price}")

    discount = markup.eqp_discount
    discount ||= 0.0
    log("EQP Discount: #{discount}")

    discount_eqp_price = eqp_price * (1 - discount)
    log("EQP Price (discounted percentage): #{discount_eqp_price}")

    self.unit_price = discount_eqp_price
  end

  def apply_price_discount(price_code = nil)
    price_code ||= product.price_code(quantity)
    self.unit_price =
      Spree::Price.discount_price(price_code, unit_price)
  end
end
