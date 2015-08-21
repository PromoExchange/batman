Spree::Product.class_eval do
  belongs_to :supplier, class_name: 'Spree::Supplier', inverse_of: :products
  has_and_belongs_to_many :imprint_methods
  has_and_belongs_to_many :option_values
  has_many :upcharges, as: :related

  def minimum_quantity
    lowest_price_range = Spree::Variant.find_by(product_id: id).volume_prices[0...-1].map(&:range).first
    return 50 if lowest_price_range.nil?
    lower_value = lowest_price_range.split('..')[0]
    lower_value.gsub(/\(/, '').to_i
  end

  def maximum_quantity
    highest_price_range = Spree::Variant.find_by(product_id: id).volume_prices[0...-1].map(&:range).last
    return 2500 if highest_price_range.nil?
    return 2500 if highest_price_range.include? '+'
    highest_value = highest_price_range.split('..')[1]
    highest_value.gsub(/\)/, '').to_i
  end

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

  def set_nondisplay_property(property_name, property_value)
    ActiveRecord::Base.transaction do
      # Works around spree_i18n #301
      property = if Property.exists?(name: property_name)
        Property.where(name: property_name).first
      else
        Property.create(name: property_name, presentation: 'NON DISPLAY')
      end

      product_property = ProductProperty.where(
        product: self,
        property: property
      ).first_or_initialize

      product_property.value = property_value
      product_property.do_not_display = true
      product_property.save!
    end
  end

  delegate :upcharges, to: :option_values
end
