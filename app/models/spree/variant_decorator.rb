Spree::Variant.class_eval do
  alias_method :orig_price_in, :price_in
  def price_in(currency)
    return orig_price_in(currency) unless volume_prices.present?
    binding.pry
    volume_price = Spree::Product.find(id).highest_discounted_volume_price
    Spree::Price.new(variant_id: id, amount: volume_price, currency: currency)
  end
end
