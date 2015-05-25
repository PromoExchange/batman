Spree::Product.class_eval do
  def all_prices
    price_ranges = Spree::Variant.where(product_id: id).first.volume_prices[0...-1].map(&:range)
    volume_prices = Spree::Variant.where(product_id: id).first.volume_prices[0...-1].map(&:amount).map(&:to_f)
    price_ranges.map(&:to_range).map { |v| v.map { volume_prices[price_ranges.map(&:to_range).index(v)] } }.flatten
  end

  def lowest_discounted_volume_price
    volume_prices = Spree::Variant.where(product_id: id).first.volume_prices

    return 0 unless volume_prices.present?
    volume_prices[-1].amount.to_f
  end

  def highest_discounted_volume_price
    volume_prices = Spree::Variant.where(product_id: id).first.volume_prices

    return nil unless volume_prices.present?
    volume_prices[0].amount.to_f
  end
end
