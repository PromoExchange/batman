module Spree::QuoteCalculator
  # TODO: Create a quote namespace
  include QuoteCalculatorUpcharge
  include QuoteCalculatorShipping
  include QuoteCalculatorFees

  private

  def best_price
    clear_log

    log('Quote: Calculating')
    log("Item name: #{product.name}")
    log("Factory: #{product.supplier.name}")
    log("Original Factory: #{product.original_supplier.name}") if product.original?
    log("SKU: #{product.master.sku}")
    log("Item Count: #{quantity}")

    log('no_eqp_range not set') if product.no_eqp_range.nil?

    eqp_applied = false
    if markup.eqp?
      eqp_applied = apply_eqp
    else
      self.unit_price = product.unit_price(quantity)
      log("Base Unit price: #{unit_price}")
    end

    apply_price_discount unless eqp_applied

    log("Running Unit price: #{unit_price}")

    # @see module QuoteCalculatorUpcharge
    apply_product_upcharges

    log("Number of imprint colors: #{num_colors}")

    apply_tax_rate

    # @see module Spree::QuoteCalculatorShipping
    apply_shipping_cost

    # @see module Spree::QuoteCalculatorShippingUpcharge
    apply_shipping_upcharge

    # @see module Spree:QuoteCalculatorFees
    apply_seller_markup
    apply_px_commission
    apply_processing_fee

    save!

    unit_price * quantity
  rescue StandardError => e
    log("ERROR: #{e}")
    Rails.logger.error(e.to_s)
    nil
  end

  def apply_eqp
    set_price = nil
    eqp_applied = false

    # Do not apply EQP if quantity is within EQP Range
    if product.no_eqp_range.present?
      log("no_eqp_range #{product.no_eqp_range}")
      bounds = product.no_eqp_range.gsub(/[()]/, '').split('..').map(&:to_i)
      range = Range.new(bounds[0], bounds[1])
      if range.member?(quantity)
        log('Turning off EQP because of no_eql_range check')
        set_price = product.unit_price(quantity)
      end
    end

    unless set_price
      eqp_price = product.eqp_price
      log('Using EQP')
      log("EQP Price (base): #{eqp_price}")

      eqp_price_code = Spree::Price.price_code_to_array(product.eqp_price_code).last
      log("EQP Applicable Price code: #{eqp_price_code}")

      eqp_price = Spree::Price.discount_price(eqp_price_code, eqp_price)
      log("EQP Discounted Price (price_code): #{eqp_price}")

      discount = markup.eqp_discount
      discount ||= 0.0
      log("EQP Discount: #{discount}")

      set_price = eqp_price * (1 - discount)
      log("EQP Price (discounted percentage): #{set_price}")
      eqp_applied = true
    end

    self.unit_price = set_price
    eqp_applied
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
