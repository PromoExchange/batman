Spree::Product.class_eval do
  belongs_to :supplier, class_name: 'Spree::Supplier', inverse_of: :products
  has_and_belongs_to_many :option_values
  has_many :upcharges, as: :related
  has_many :color_product

  has_many :imprint_methods_products, class_name: 'Spree::ImprintMethodsProduct'
  has_many :imprint_methods, through: :imprint_methods_products

  delegate :upcharges, to: :option_values

  state_machine initial: :active do
    after_transition on: :invalid, do: :unavailable
    after_transition on: :loaded, do: :available

    event :loading do
      transition [:active, :loading, :invalid, :deleted] => :loading
    end

    event :invalid do
      transition loading: :invalid
    end

    event :loaded do
      transition [:invalid, :loading] => :active
    end

    event :deleted do
      transition active: :deleted
    end
  end

  def wearable?
    # Assume wearable as having Apparal as parent
    apparel_taxon = Spree::Taxon.where(dc_category_guid: '7F4C59A7-6226-11D4-8976-00105A7027AA')
    children = Spree::Taxon.where(parent: apparel_taxon).pluck(:id)
    Spree::Classification.where(product: self).find_each do |classification|
      return true if children.include?(classification.taxon_id)
    end
    false
  end

  def minimum_quantity
    # HACK: for SanMar
    sanmar = Spree::Supplier.where(dc_acct_num: '100160').first
    return 12 if supplier == sanmar
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

  def remove_all_properties
    Spree::ProductProperty.where(product: self).destroy_all
  end

  def set_nondisplay_property(property_name, property_value)
    ActiveRecord::Base.transaction do
      # Works around spree_i18n #301
      property = if Spree::Property.exists?(name: property_name)
                   Spree::Property.find_by(name: property_name)
                 else
                   Spree::Property.create(
                     name: property_name,
                     presentation: 'NON DISPLAY'
                   )
                 end

      product_property = Spree::ProductProperty.where(
        product: self,
        property: property
      ).first_or_initialize

      product_property.value = property_value
      product_property.do_not_display = true
      product_property.save!
    end
  end

  def get_property_value(key)
    shipping_weight_id = Spree::Property.all.find_by_name(key).id
    return if shipping_weight_id.nil?
    prop = product_properties.find_by(property_id: shipping_weight_id)
    return if prop.nil?
    prop.value
  end

  def prebid_ability!
    self.shipping_weight ||= get_property_value('shipping_weight')
    self.shipping_dimensions ||= get_property_value('shipping_dimensions')
    self.shipping_quantity ||= get_property_value('shipping_quantity')
    save!

    got_shipping_weight = shipping_weight.present?
    got_shipping_dimensions = shipping_dimensions.present?
    got_shipping_quantity = shipping_quantity.present?
    got_originating_zip = originating_zip.present?

    got_shipping_weight &&
      got_shipping_dimensions &&
      got_shipping_quantity &&
      got_originating_zip
  end

  def check_validity!
    no_imprint_methods = Spree::ImprintMethodsProduct.where(product: self).empty?
    no_main_color = Spree::ColorProduct.where(product: self).empty?
    invalid if no_imprint_methods || no_main_color
  rescue
    Rails.logger.warn('Failed to test for validity, assume invalid')
    invalid
  end

  def unavailable
    update_attribute(:available_on, 100.years.from_now)
  end

  def available
    update_attribute(:available_on, Time.zone.now)
  end

  def load_image(supplier_item_guid)
    return unless Rails.configuration.x.load_images
    begin
      images.destroy_all # Only one image allowed
      images << Spree::Image.create!(
        attachment: Spree::DcImage.retrieve(supplier_item_guid),
        viewable: self
      )
    rescue StandardError => e
      Rails.logger.warn("PLOAD: Warning: Unable to load product image [#{supplier_item_guid}], #{e.message}")
    end
  end

  def remove_all_categories
    Spree::Classification.where(product_id: id).destroy_all
  end

  def add_category(category_guid)
    taxon = Spree::Taxon.find_by(dc_category_guid: category_guid)

    return if taxon.nil?

    Spree::Classification.where(
      taxon_id: taxon.id,
      product_id: id
    ).first_or_create
  end

  def self.csv_header
    CSV::Row.new([:sku, :name, :factory, :num_product_colors, :num_imprints],
      %w(sku name factory num_product_colors num_imprints), true)
  end

  def to_csv_row
    CSV::Row.new([:sku, :name, :factory, :num_product_colors, :num_imprints],
      [sku, name, supplier.name, color_product.count, imprint_methods.count])
  end

  def self.find_in_batches(dc_acct_num)
    supplier = Spree::Supplier.find_by(dc_acct_num: dc_acct_num)
    where(supplier: supplier).find_each do |product|
      yield product
    end
  end
end
