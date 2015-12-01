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
    # supplier_item_guid = params[:supplier_item_guid]
    Rails.logger.info("PLOAD: Product loading [#{supplier_item_guid}]")

    px_product = Spree::Product.where(supplier_item_guid: supplier_item_guid).first
    fail 'Unable to locate DB record' if px_product.nil?

    dc_product = Spree::DcFullProduct.retrieve(supplier_item_guid)

    unless dc_product.valid?
      Rails.logger.info("PLOAD: Retrieved DC product is invalid [#{supplier_item_guid}]")
      px_product.invalid
      return
    end

    # Update attributes
    sanitized_string = ActionView::Base.full_sanitizer.sanitize(dc_product.description)
    px_product.update_attributes(
      description: sanitized_string,
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
      px_product.shipping_weight = dc_product.packaging.weight
    end

    if dc_product.packaging.dimensions
      properties << "shipping_dimensions: #{dc_product.packaging.dimensions}" if dc_product.packaging.dimensions
      px_product.shipping_dimensions = dc_product.packaging.dimensions
    end

    if dc_product.packaging.quantity
      properties << "shipping_quantity: #{dc_product.packaging.quantity}" if dc_product.packaging.quantity
      px_product.shipping_quantity = dc_product.packaging.quantity
    end

    properties.each do |property|
      property_vals = property.split(':')
      px_product.set_property(property_vals[0].strip.humanize, property_vals[1].strip)
    end

    # Sets a 'default' color,
    # If there is a PRODUCT COLORS option it will override this
    Spree::ColorProduct.where(
      product_id: px_product.id,
      color: px_product.supplier_display_name
    ).first_or_create

    # Image
    px_product.load_image supplier_item_guid

    # Categories
    Rails.logger.debug("PLOAD: Loading #{dc_product.categories.count} categories")
    px_product.remove_all_categories
    dc_product.categories.each do |category|
      begin
        px_product.add_category(category.guid)
      rescue StandardError => e
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
        upcharge_type_id = Spree::UpchargeType.where(name: 'setup').first.id

        upcharge_attrs = {
          upcharge_type_id: upcharge_type_id,
          related_id: px_product.id,
          actual: 'setup',
          price_code: price.code,
          value: price.retail,
          range: nil
        }
        Spree::UpchargeProduct.create(upcharge_attrs)
      else
        unless last_price.nil?
          range = "(#{last_price.qty}..#{price.qty.to_i - 1})"

          last_volume_price = Spree::VolumePrice.create!(
            variant: px_product.master,
            name: range,
            range: range,
            amount: last_price.retail,
            position: range_count,
            discount_type: 'price'
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
      discount_type: 'price'
    )

    # Options
    Rails.logger.debug("PLOAD: Loading #{dc_product.options.count} options")
    dc_product.options.each do |option|
      if option.type == 'Decoration Information'
        option_detail = Spree::DcOptionDetail.retrieve(option.guid)

        imprint_name = option_detail.name.strip

        Rails.logger.debug("PLOAD: Option name [#{imprint_name}]")

        dc_acct_num = px_product.supplier.dc_acct_num

        option_mapping = Spree::OptionMapping.where(
          dc_acct_num: dc_acct_num,
          dc_name: imprint_name
        ).first_or_create

        next if option_mapping.do_not_save?

        imprint_name = option_mapping.px_name unless option_mapping.px_name.blank?

        # Imprint Methods
        imprint_method = Spree::ImprintMethod.where(
          name: imprint_name
        ).first_or_create

        Spree::PmsColorsSupplier.where(
          imprint_method_id: imprint_method.id,
          supplier_id: px_product.supplier_id
        ).destroy_all

        option_detail.option_choices.each do |option_choice|
          next if option_choice.name == 'PMS Color Match'

          pms_color = Spree::PmsColor.where(
            name: option_choice.name
          ).first_or_create

          pantone = pms_color.display_name
          pantone ||= option_choice.name

          Spree::PmsColorsSupplier.where(
            pms_color_id: pms_color.id,
            display_name: pantone,
            supplier_id: px_product.supplier_id,
            imprint_method_id: imprint_method.id
          ).first_or_create
        end
        Spree::ImprintMethodsProduct.where(
          imprint_method_id: imprint_method.id,
          product_id: px_product.id
        ).first_or_create
      elsif option.type == 'Product Color Information'
        Spree::ColorProduct.where(
          product_id: px_product.id
        ).destroy_all

        option_detail = Spree::DcOptionDetail.retrieve(option.guid)
        option_detail.option_choices.each do |option_choice|
          cleaned_color_name = clean_color_name(option_choice.name)
          Spree::ColorProduct.where(
            product_id: px_product.id,
            color: cleaned_color_name
          ).first_or_create
        end
      else
        Rails.logger.warn("PLOAD: *** Unseen option type [#{option.type}]")
      end
    end

    # :imprint_areas,
    # :packaging
    Rails.logger.debug("PLOAD: Loading #{dc_product.options.count} packaging")
    px_product.originating_zip = dc_product.packaging.orig_zip if dc_product.packaging.orig_zip
    px_product.shipping_quantity = dc_product.packaging.quantity if dc_product.packaging.quantity
    px_product.shipping_weight = dc_product.packaging.weight if dc_product.packaging.weight
    px_product.shipping_dimensions = dc_product.packaging.dimensions if dc_product.packaging.dimensions

    px_product.save!
    px_product.check_validity!
    px_product.loaded if px_product.state == 'loading'

    elapsed = (Time.zone.now - beginning_time) * 1000
    Rails.logger.info("PLOAD: [#{supplier_item_guid}] Load took: #{elapsed.round(3)}ms")
  rescue StandardError => e
    Rails.logger.error("PLOAD: Failed to load [#{supplier_item_guid}] Reason: #{e.message}")
    supplier_item_guid = params['supplier_item_guid']
    px_product = Spree::Product.where(supplier_item_guid: supplier_item_guid).first
    px_product.invalid if px_product
  end
end
