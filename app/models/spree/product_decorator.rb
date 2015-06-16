Spree::Product.class_eval do
  belongs_to :supplier, class_name: 'Spree::Supplier', inverse_of: :products
  has_and_belongs_to_many :imprint_methods
  has_and_belongs_to_many :option_values
  has_many :upcharges, as: :related

  # TODO: Removed because sample data will not load
  # validates :supplier_id, presence: true

  def all_prices
    price_ranges = Spree::Variant.find_by(product_id: id).volume_prices[0...-1].map(&:range)
    volume_prices = Spree::Variant.find_by(product_id: id).volume_prices[0...-1].map(&:amount).map(&:to_f)
    price_ranges.map(&:to_range).map { |v| v.map { volume_prices[price_ranges.map(&:to_range).index(v)] } }.flatten
  end

  def lowest_discounted_volume_price
    volume_prices = Spree::Variant.find_by(product_id: id).volume_prices

    return 0 unless volume_prices.present?
    volume_prices.last.amount.to_f
  end

  def highest_discounted_volume_price
    volume_prices = Spree::Variant.find_by(product_id: id).volume_prices

    return 0 unless volume_prices.present?
    volume_prices.first.amount.to_f
  end

  def upcharges
    option_values.upcharges
  end
end
