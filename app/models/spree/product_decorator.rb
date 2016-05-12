Spree::Product.class_eval do
  include Preconfigure

  before_create :build_default_carton
  belongs_to :supplier, class_name: 'Spree::Supplier', inverse_of: :products
  has_many :upcharges, class_name: 'Spree::UpchargeProduct', foreign_key: 'related_id'
  has_many :color_product
  has_one :carton, dependent: :destroy
  belongs_to :original_supplier, class_name: 'Spree::Supplier', inverse_of: :products

  has_many :imprint_methods_products, class_name: 'Spree::ImprintMethodsProduct'
  has_many :imprint_methods, through: :imprint_methods_products

  has_many :price_caches

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
    sanmar = Spree::Supplier.where(dc_acct_num: '100160').first
    return 12 if supplier == sanmar
    lowest_price_range = Spree::Variant.find_by(product_id: id).volume_prices[0..-1].map(&:range).first
    return 50 if lowest_price_range.nil?
    lower_value = lowest_price_range.split('..')[0]
    lower_value.gsub(/\(/, '').to_i
  end

  def maximum_quantity
    highest_price_range = Spree::Variant.find_by(product_id: id).volume_prices[0..-1].map(&:range).last
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

  def eqp_price
    last_price = Spree::Variant.find_by(product_id: id).volume_prices[0..-1].last
    return last_price.amount.to_f if last_price.present?
    0.0
  rescue
    0.0
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

  def lowest_unit_price
    refresh_price_cache
    lowest_cache = price_caches.order(:position).last
    lowest_range = lowest_cache.range.split('..')[0].gsub(/\D/, '').to_i
    lowest_cache.lowest_price.to_f / lowest_range
  rescue StandardError => e
    Rails.logger.error("Failed to get lowest price, #{e.message}")
  end

  def refresh_price_cache
    # We can only calcuate prices for products that have custom auctions
    custom_auction = Spree::Auction.find_by(product_id: id, state: 'custom_auction')
    fail 'refresh_price_cache called for non custom product' if custom_auction.nil?

    how_old = ENV['PRICE_CACHE_REFRESH_HOURS']
    how_old ||= 24

    oldest_record = price_caches.order('updated_at').first
    oldest_date = oldest_record.updated_at if oldest_record.present?
    oldest_date ||= how_old.hours.ago - 1.hour

    if how_old.hours.ago > oldest_date
      price_caches.destroy_all

      Spree::Variant.find_by(product_id: id).volume_prices(order: 'position asc').each do |price|
        lowest_range = price.range.split('..')[0].gsub(/\D/, '')
        best_price = custom_auction.best_price(lowest_range.to_i, Spree::Prebid::SHIPPING_OPTION[:ups_ground])

        price_caches << Spree::PriceCache.create!(
          range: price.range,
          lowest_price: best_price.order.total.to_f,
          position: price.position
        )
      end
    end
  rescue StandardError => e
    Rails.logger.error("Failed to calculate price cache, #{e.message}")
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
      %w(sku name factory num_product_colors num_imprints num_upcharges_setup num_upcharges_run num_prices shipping_weight shipping_dimensions shipping_quantity shipping_originating_zip), true)
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
      ])
  end

  def self.find_in_batches(dc_acct_num)
    supplier = Spree::Supplier.find_by(dc_acct_num: dc_acct_num)
    where(supplier: supplier).find_each do |product|
      yield product
    end
  end

  private

  def build_default_carton
    build_carton
  end
end
