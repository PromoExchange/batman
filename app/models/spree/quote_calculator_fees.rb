module Spree::QuoteCalculatorFees
  def apply_seller_markup
    # Seller markup
    seller_markup = markup.markup.to_f || 0.0

    # TODO: Hack For Yeti Add price adjustments table
    seller_markup = 0.057773719921 if product.master.sku == 'PC-YRAM20'

    log("Applying markup: #{seller_markup}")
    self.unit_price *= (1 + seller_markup)
    log("After applying markup: #{unit_price}")
  end

  def apply_px_commission
    log("Applying PX commission: #{px_commission_rate}")
    self.unit_price /= (1 - px_commission_rate)
    log("After applying commission: #{self.unit_price}")
  end

  def apply_processing_fee
    log('Applying processing cost:')
    log("Payment processing commission: #{payment_processing_commission}")
    log("Payment processing flat fee: #{payment_processing_flat_fee}")
    self.unit_price /= (1 - payment_processing_commission)
    self.unit_price += (payment_processing_flat_fee / quantity)
    log("After applying processing cost: #{self.unit_price}")
  end
end
