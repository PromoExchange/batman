Spree::Price.class_eval do
  def self.discount_codes
    {
      A: 0.50,
      B: 0.55,
      C: 0.60,
      D: 0.65,
      E: 0.70,
      F: 0.75,
      G: 0.80,
      H: 0.85,
      I: 0.90,
      J: 0.95,
      K: 1.00,
      P: 0.50,
      Q: 0.55,
      R: 0.60,
      S: 0.65,
      T: 0.70,
      U: 0.75,
      V: 0.80,
      W: 0.85,
      X: 0.90,
      Y: 0.95,
      Z: 1.00
    }.freeze
  end

  def self.discount_price(code, price)
    return price if code.nil?
    return nil if price.nil?
    discount = Spree::Price.discount_codes[code.to_sym]
    discount.nil? ? price : (price * discount)
  end
end
