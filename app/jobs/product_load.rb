module ProductLoad
  @queue = :product_load

  def self.clean_color_name(name)
    bits = name.split('-')
    return name unless bits.count > 1
    return bits[1].strip! unless bits[1].strip.empty?
    bits[0].strip
  end

  def self.perform(params)
    beginning_time = Time.zone.now

    supplier_item_guid = params['supplier_item_guid']
    Rails.logger.info("PLOAD: Product loading [#{supplier_item_guid}]")

    px_product = Spree::Product.where(supplier_item_guid: supplier_item_guid).first
    fail 'Unable to locate DB record' if px_product.nil?

    dc_product = DistributorCentral::FullProduct.retrieve(supplier_item_guid)

    unless dc_product.valid?
      Rails.logger.info("PLOAD: Retrieved DC product is invalid [#{supplier_item_guid}]")
      px_product.invalid
      return
    end

    px_product.update_attributes(
      description: ActionView::Base.full_sanitizer.sanitize(dc_product.description),
      size: dc_product.size,
      weight: dc_product.weight
    )

    # Properties
    px_product.remove_all_properties
    properties = []
    properties << "country_of_origin: #{dc_product.country_name}" if dc_product.country_name
    properties << "production_time: #{dc_product.production_time} business days" if dc_product.production_time
    properties << "size: #{dc_product.size}" if dc_product.size
    properties << "weight: #{dc_product.weight}" if dc_product.weight
    properties << "additional_info: #{dc_product.add_info}" if dc_product.add_info

    # N.B. Needed for prebid (well..as soon as prebid uses attributes)
    if dc_product.packaging.weight
      properties << "shipping_weight: #{dc_product.packaging.weight}"
      px_product.carton.weight = dc_product.packaging.weight
    end

    if dc_product.packaging.dimensions
      properties << "shipping_dimensions: #{dc_product.packaging.dimensions}" if dc_product.packaging.dimensions
      dimensions = dc_product.packaging.dimensions.gsub(/[A-Z]/, '').delete(' ').split('x')
      px_product.carton.length = dimensions[0]
      px_product.carton.width = dimensions[1] if dimensions.count > 1
      px_product.carton.height = dimensions[2] if dimensions.count > 2
    end

    if dc_product.packaging.quantity
      properties << "shipping_quantity: #{dc_product.packaging.quantity}" if dc_product.packaging.quantity
      px_product.carton.quantity = dc_product.packaging.quantity
    end

    px_product.carton.originating_zip = dc_product.packaging.orig_zip if dc_product.packaging.orig_zip

    properties.each do |property|
      property_vals = property.split(':')
      px_product.set_property(property_vals[0].strip.humanize, property_vals[1].strip)
    end

    # Sets a 'default' color,
    # If there is a PRODUCT COLORS option it will override this
    unless px_product.supplier_display_name.blank?
      Spree::ColorProduct.where(product: px_product, color: px_product.supplier_display_name).first_or_create
    end

    # Image
    px_product.load_image supplier_item_guid

    # Categories
    Rails.logger.debug("PLOAD: Loading #{dc_product.categories.count} categories")
    px_product.remove_all_categories
    dc_product.categories.each do |category|
      begin
        px_product.add_category(category.guid)
      rescue e
        Rails.logger.warn("PLOAD: [#{supplier_item_guid}] Unable to associate [#{category.name}]. Reason: #{e.message}")
      end
    end

    # Price
    Rails.logger.debug("PLOAD: Loading #{dc_product.prices.count} prices")
    Spree::VolumePrice.where(variant: px_product.master).destroy_all
    last_price = nil
    range_count = 1
    last_volume_price = nil
    dc_product.prices.each do |price|
      if price.issetup == '1'
        Spree::UpchargeProduct.create(
          upcharge_type: Spree::UpchargeType.where(name: 'setup').first,
          related_id: px_product.id,
          actual: 'setup',
          price_code: price.code,
          value: price.retail,
          range: nil
        )
      else
        unless last_price.nil?
          range = "(#{last_price.qty}..#{price.qty.to_i - 1})"

          last_volume_price = Spree::VolumePrice.create!(
            variant: px_product.master,
            name: range,
            range: range,
            amount: last_price.retail,
            position: range_count,
            discount_type: 'price',
            price_code: last_price.code
          )

          range_count += 1
        end

        last_price = price
      end
    end

    range = "#{last_price.qty}+"
    Spree::VolumePrice.create!(
      variant: px_product.master,
      name: range,
      range: range,
      amount: last_price.retail,
      position: range_count,
      discount_type: 'price',
      price_code: last_price.code
    )

    # Options
    Rails.logger.debug("PLOAD: Loading #{dc_product.options.count} options")
    dc_product.options.each do |option|
      if option.type == 'Decoration Information'
        option_detail = DistributorCentral::OptionDetail.retrieve(option.guid)

        Rails.logger.debug("PLOAD: Option name [#{option_detail.name.strip}]")

        option_mapping = Spree::OptionMapping.where(
          dc_acct_num: px_product.supplier.dc_acct_num,
          dc_name: option_detail.name.strip
        ).first_or_create
        next if option_mapping.do_not_save?

        imprint_method = Spree::ImprintMethod.where(name: option_detail.name.strip).first_or_create

        Spree::PmsColorsSupplier.where(imprint_method: imprint_method, supplier: px_product.supplier).destroy_all

        option_detail.option_choices.each do |option_choice|
          next if option_choice.name == 'PMS Color Match'

          pms_color = Spree::PmsColor.where(name: option_choice.name).first_or_create
          Spree::PmsColorsSupplier.where(
            pms_color: pms_color,
            display_name: pms_color.display_name || option_choice.name,
            supplier: px_product.supplier,
            imprint_method: imprint_method
          ).first_or_create
        end

        Spree::ImprintMethodsProduct.where(imprint_method: imprint_method, product: px_product).first_or_create
      elsif option.type == 'Product Color Information'
        option_detail = DistributorCentral::OptionDetail.retrieve(option.guid)
        Spree::ColorProduct.where(product: px_product).destroy_all if option_detail.option_choices.count > 0

        option_detail.option_choices.each do |option_choice|
          Spree::ColorProduct.where(product: px_product, color: clean_color_name(option_choice.name)).first_or_create
        end
      else
        Rails.logger.warn("PLOAD: *** Unseen option type [#{option.type}]")
      end
    end

    px_product.save!
    px_product.check_validity!
    px_product.loaded! if px_product.state == 'loading'

    elapsed =
    Rails.logger.info("PLOAD: [#{supplier_item_guid}]: #{((Time.zone.now - beginning_time) * 1000).round(3)}ms")
  rescue e
    Rails.logger.error("PLOAD: Failed to load [#{supplier_item_guid}] Reason: #{e.message}")
    px_product = Spree::Product.where(supplier_item_guid: params['supplier_item_guid']).first
    px_product.invalid if px_product
  end
end
