Spree::Product.class_eval do
  before_create :build_default_carton
  after_save :clear_cache

  belongs_to :supplier, class_name: 'Spree::Supplier', inverse_of: :products
  has_many :upcharges, class_name: 'Spree::UpchargeProduct', foreign_key: 'related_id'
  has_many :color_product
  has_one :carton, dependent: :destroy
  belongs_to :original_supplier, class_name: 'Spree::Supplier', inverse_of: :products
  has_one :preconfigure, dependent: :destroy
  has_many :purchase

  has_many :imprint_methods_products, class_name: 'Spree::ImprintMethodsProduct'
  has_many :imprint_methods, through: :imprint_methods_products, inverse_of: :products

  has_many :price_caches
  has_many :quotes

  accepts_nested_attributes_for :upcharges, :imprint_methods_products

  validates_associated :carton

  state_machine initial: :active do
    after_transition on: :invalid, do: :unavailable
    after_transition on: :loaded, do: :available

    event :loading do
      transition [:active, :loading, :invalid, :deleted] => :loading
    end

    event :invalid do
      transition [:active, :loading, :invalid] => :invalid
    end

    event :loaded do
      transition [:invalid, :loading] => :active
    end

    event :deleted do
      transition active: :deleted
    end
  end

  delegate :fixed_price_shipping?, to: :carton

  def clear_cache
    quotes.each do |q|
      Rails.cache.delete("#{q.cache_key}/total_price")
    end
    quotes.destroy_all
  end

  def company_store
    # TODO: Direct association once we move the preconfigure in
    return nil if supplier.nil?
    Rails.cache.fetch("#{cache_key}/supplier", expires_in: 5.minutes) do
      Spree::CompanyStore.find_by_supplier_id(supplier.id)
    end
  end

  def markup
    Rails.cache.fetch("#{cache_key}/markup", expires_in: 5.minutes) do
      Spree::Markup.find_by(supplier: original_supplier, company_store: company_store)
    end
  end

  # TODO: ImprintMethods will turn into a has_one
  # This will depend on what we decide to do with preconfigure
  # For now we will *fake* a has_one my having a singular
  def imprint_method
    Rails.cache.fetch("#{cache_key}/imprint_method", expires_in: 5.minutes) do
      imprint_methods.first
    end
  end

  def volume_prices
    Spree::Variant.find_by(product_id: id).volume_prices
  end

  def wearable?
    # Assume wearable as having Apparal as parent OR as it's main category
    apparel_taxon = Spree::Taxon.where(dc_category_guid: '7F4C59A7-6226-11D4-8976-00105A7027AA')
    return true if Spree::Classification.find_by(product: self, taxon: apparel_taxon).present?

    # Check the children
    children = Spree::Taxon.where(parent: apparel_taxon).pluck(:id)
    Spree::Classification.where(product: self).find_each do |classification|
      return true if children.include?(classification.taxon_id)
    end
    false
  end

  def minimum_quantity
    # HACK: for SanMar
    sanmar = Spree::Supplier.find_by(dc_acct_num: '100160')
    return 12 if supplier == sanmar
    lowest_price_range = volume_prices[0..-1].map(&:range).first
    return 50 if lowest_price_range.nil?
    lower_value = lowest_price_range.split('..')[0]
    lower_value.delete('(').to_i
  end

  def maximum_quantity
    highest_price_range = volume_prices.map(&:range).last
    return 2500 if highest_price_range.nil?
    # TODO: I think we should actually be 2 x last_price_break_minimum
    return 2500 if highest_price_range.include? '+'
    highest_value = highest_price_range.split('..')[1]
    highest_value.delete(')').to_i
  end

  def last_price_break_minimum
    last_price_break_minimum = volume_prices.map(&:range).last
    return last_price_break_minimum.split('+')[0].to_i if last_price_break_minimum.include? '+'
    last_price_break_minimum = last_price_break_minimum.split('..')[1]
    last_price_break_minimum.delete(')').to_i
  end

  def all_prices
    price_ranges = Spree::Variant.find_by(product_id: id).volume_prices[0...-1].map(&:range)
    volume_prices = Spree::Variant.find_by(product_id: id).volume_prices[0...-1].map(&:amount).map(&:to_f)
    price_ranges.map(&:to_range).map { |v| v.map { volume_prices[price_ranges.map(&:to_range).index(v)] } }.flatten
  end

  def eqp_price
    last_price = Spree::Variant.find_by(product_id: id).volume_prices[0..-1].last
    return last_price.amount.to_f if last_price.present?
    0.0
  rescue
    Rails.logger.error('Failed to get eqp_price, defaulting to 0.0')
    0.0
  end

  def eqp_price_code
    Spree::Variant.find_by(product_id: id).volume_prices[0..-1].last.price_code.last
  rescue
    Rails.logger.error('Failed to get eqp_price_code, defaulting to V')
    'V'
  end

  def lowest_discounted_volume_price
    volume_prices = Spree::Variant.find_by(product: self).volume_prices

    return 0 unless volume_prices.present?
    volume_prices.last.amount.to_f
  end

  def highest_discounted_volume_price
    volume_prices = Spree::Variant.find_by(product: self).volume_prices

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
    property_id = Spree::Property.all.find_by_name(key).id
    return if property_id.nil?
    property = product_properties.find_by(property_id: property_id)
    return if property.nil?
    prop.value
  end

  def prebid_ability?
    carton.active? && upcharges.count > 0 && Spree::Variant.find_by(product_id: id).volume_prices.count > 0
  end

  def setup_upcharges
    upcharges.where(upcharge_type: Spree::UpchargeType.where(name: 'setup'))
  end

  def run_upcharges
    upcharges.where(upcharge_type: Spree::UpchargeType.where(name: %w(run additional_color_run)))
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

  def unit_price(quantity)
    return 0.0 if quantity.nil?
    unit_price = price
    master.volume_prices.each do |v|
      if v.open_ended? || (v.range.to_range.begin..v.range.to_range.end).cover?(quantity)
        unit_price = v.amount
        break
      end
    end
    unit_price
  end

  def price_code(quantity = nil)
    quantity ||= minimum_quantity
    price_code = nil
    price_code_count = 0
    master.volume_prices.each do |v|
      next unless v.open_ended? || (v.range.to_range.begin..v.range.to_range.end).cover?(quantity)
      price_code = v.price_code

      # It is possible that the price code is actually the entire price code
      # Break it out and select the correct one
      if price_code.length > 1
        price_code_array = Spree::Price.price_code_to_array(price_code)
        if price_code_array.length >= price_code_count
          price_code = price_code_array[price_code_count]
        end
      end
      break
    end
    price_code || 'V'
  end

  def lowest_unit_price
    refresh_price_cache
    lowest_cache = price_caches.order(:position).last
    lowest_range = lowest_cache.range.split('..')[0].gsub(/\D/, '').to_i
    lowest_cache.lowest_price.to_f / lowest_range
  rescue StandardError => e
    Rails.logger.error("Failed to get lowest price, #{e.message}")
  end

  def available_shipping_options
    unless fixed_price_shipping?
      return Spree::Quote.shipping_options.except('fixed_price_per_item', 'fixed_price_total')
    end
    carton.per_item ? ['fixed_price_per_item'] : ['fixed_price_total']
  end

  def valid_shipping_option?(shipping_option)
    available_shipping_options.include?(shipping_option.to_s)
  end

  def best_price(options = {})
    raise 'Cannot find buyer' if company_store.buyer.nil?
    raise 'Cannot find default shipping adddress' if company_store.buyer.shipping_address.nil?
    if options[:shipping_option].nil? && fixed_price_shipping?
      options[:shipping_option] = carton.per_item? ? :fixed_price_per_item : :fixed_price_total
    end
    raise 'Invalid shipping option requested' unless valid_shipping_option?(options[:shipping_option] || :ups_ground)

    options.reverse_merge!(
      quantity: last_price_break_minimum,
      shipping_option: :ups_ground,
      shipping_address: company_store.buyer.shipping_address.id
    )

    options[:quantity] ||= last_price_break_minimum

    quote = quotes.where(
      quantity: options[:quantity].to_i,
      main_color: preconfigure.main_color,
      shipping_address: options[:shipping_address].to_i,
      custom_pms_colors: preconfigure.custom_pms_colors,
      shipping_option: options[:shipping_option]
    ).first_or_create

    raise 'Failed to get price' if quote.nil?

    total_price = quote.total_price(shipping_option: options[:shipping_option])

    if total_price.nil?
      return {
        error_code: quote.error_code.to_s,
        error_message: quote.messages.last,
        best_price: nil,
        delivery_days: nil
      }
    end

    response = {
      quote_id: quote.id,
      best_price: total_price,
      shipping_option: quote.shipping_option,
      quantity: options[:quantity].to_i,
      delivery_days: production_time + quote.shipping_days
    }

    response
  rescue StandardError => e
    Rails.logger.error("Failed to get best price: #{e}")
    { best_price: 0.0, delivery_days: 14 }
  end

  def price_breaks
    breaks = Spree::Variant.find_by(product_id: id)
      .volume_prices(order: 'position asc')
    breaks.map(&:range)
  end

  def load_image(supplier_item_guid)
    return unless Rails.configuration.x.load_images
    begin
      images.destroy_all # Only one image allowed
      images << Spree::Image.create!(
        attachment: DistributorCentral::Image.retrieve(supplier_item_guid),
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
    CSV::Row.new(
      [
        :sku,
        :name,
        :factory,
        :num_product_colors,
        :num_imprints,
        :num_upcharges_setup,
        :num_upcharges_run,
        :num_prices,
        :shipping_weight,
        :shipping_dimensions,
        :shipping_quantity,
        :shipping_originating_zip
      ],
      %w(
        sku
        name
        factory
        num_product_colors
        num_imprints
        num_upcharges_setup
        num_upcharges_run
        num_prices
        shipping_weight
        shipping_dimensions
        shipping_quantity
        shipping_originating_zip
      ),
      true
    )
  end

  def to_csv_row
    setup_type = Spree::UpchargeType.where(name: 'setup').first_or_create
    run_type = Spree::UpchargeType.where(name: 'run').first_or_create

    CSV::Row.new(
      [
        :sku,
        :name,
        :factory,
        :num_product_colors,
        :num_imprints,
        :num_upcharges_setup,
        :num_upcharges_run,
        :num_prices,
        :shipping_weight,
        :shipping_dimensions,
        :shipping_quantity,
        :shipping_originating_zip
      ],
      [
        sku,
        name,
        supplier.name,
        color_product.count,
        imprint_methods.count,
        upcharges.where(upcharge_type: setup_type).count,
        upcharges.where(upcharge_type: run_type).count,
        Spree::Variant.find_by(product: self).volume_prices.count,
        carton.weight,
        carton.to_s,
        carton.quantity,
        carton.originating_zip
      ]
    )
  end

  def self.find_in_batches(dc_acct_num)
    supplier = Spree::Supplier.find_by(dc_acct_num: dc_acct_num)
    where(supplier: supplier).find_each do |product|
      yield product
    end
  end

  def cache_key
    "#{model_name.cache_key}/#{id || 'new'}"
  end

  private

  def build_default_carton
    build_carton
  end
end
