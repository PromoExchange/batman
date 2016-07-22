module Spree::QuoteCalculator
  # TODO: Create a quote namespace
  include QuoteCalculatorUpcharge
  include QuoteCalculatorShipping

  def calculate(options = {})
    clear_log

    [
      :selected_shipping_option
    ].each do |o|
      raise "Cannot calculate quote, missing required option [#{o}]" unless options.key?(o)
    end

    log('Quote: Calculating')
    log("Item name: #{product.name}")
    log("Factory: #{product.supplier.name}")
    log("Original Factory: #{product.original_supplier.name}")
    log("SKU: #{product.master.sku}")
    log("Item Count: #{quantity}")

    if markup.eqp?
      apply_eqp
    else
      self.unit_price = product.unit_price(quantity)
      log("Base Unit price: #{unit_price}")
      apply_price_discount
    end
    log("Running Unit price: #{unit_price}")

    # @see module QuoteCalculatorUpcharge
    apply_product_upcharges

    log("Number of imprint colors: #{num_colors}")

    apply_tax_rate

    # @see module Spree::QuoteCalculatorShipping
    # @note: Unit price is *not* adjusted in calculate_shipping
    shipping_cost = calculate_shipping

    log("Selected Shipping cost #{shipping_cost}")
    log("Selected Shipping option #{Spree::ShippingOption::OPTION.key(selected_shipping_option)}")
    unit_price_with_shipping = unit_price + (shipping_cost / quantity)
    log("After applying shipping #{unit_price_with_shipping}")

    save!

    unit_price_with_shipping * quantity
  rescue StandardError => e
    log(e.to_s)
    Rails.logger.error(e.to_s)
    0.0
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
    log("Discounting price with code [#{price_code}]")
    log("Before discount running unit price[#{unit_price}]")
    self.unit_price =
      Spree::Price.discount_price(price_code, unit_price)
    log("Post discount running unit price[#{unit_price}]")
  end

  def apply_tax_rate
    tax_rate = 0.0
    seller = company_store.seller
    log('WARN: Failed to find company store seller') if seller.nil?

    tax_rate = seller.tax_rate(shipping_address) unless seller.nil?

    log("Applying tax rate #{tax_rate}")
    self.unit_price /= (1 - tax_rate)
    log("After applying tax rate: #{self.unit_price}")
  end
end
