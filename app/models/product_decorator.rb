Spree::Product.class_eval do
  def all_prices
    price_ranges = Spree::Variant.where(product_id: id).first.volume_prices[0...-1].map(&:range)
    volume_prices = Spree::Variant.where(product_id: id).first.volume_prices[0...-1].map(&:amount).map(&:to_f)
    price_ranges.map(&:to_range).map { |v| v.map { volume_prices[price_ranges.map(&:to_range).index(v)] } }.flatten
  end

  def lowest_discounted_volume_price
    Spree::Variant.where(product_id: id).first.volume_prices[-1].amount.to_f
  end
end
