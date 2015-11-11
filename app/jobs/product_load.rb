module ProductLoad
  @queue = :product_load

  def self.perform(params)
    beginning_time = Time.zone.now

    supplier_item_guid = params['supplier_item_guid']
    # supplier_item_guid = params[:supplier_item_guid]
    Rails.logger.info("PLOAD: Product loading #{supplier_item_guid}")

    px_product = Spree::Product.where(supplier_item_guid: supplier_item_guid).first
    fail 'Unable to locate DB record' if px_product.nil?

    # http://www.distributorcentral.com/resources/xml/item_information.cfm?acctwebguid=F616D9EB-87B9-4B32-9275-0488A733C719&supplieritemguid=3D0F1C12-E3F6-11D3-896A-00105A7027AA
    # http://www.distributorcentral.com/resources/xml/item_information.cfm?acctwebguid=F616D9EB-87B9-4B32-9275-0488A733C719&supplieritemguid=90A5528D-E38E-46B7-BE27-7EB1489D0C7B
    # http://www.distributorcentral.com/resources/xml/item_information.cfm?acctwebguid=F616D9EB-87B9-4B32-9275-0488A733C719&supplieritemguid=0681AC44-CCBB-4FFA-A231-8211A328F98C

    dc_product = Spree::DcFullProduct.retrieve(supplier_item_guid)

    unless dc_product.valid?
      px_product.invalid
      return
    end

    # Update attributes
    px_product.update_attributes(
      description: dc_product.description,
      size: dc_product.size,
      weight: dc_product.weight
    )

    # Properties
    properties = []
    properties << "country_of_origin: #{dc_product.country_name}" if dc_product.country_name
    properties << "production_time: #{dc_product.production_time}" if dc_product.production_time
    properties << "size: #{dc_product.size}" if dc_product.size
    properties << "weight: #{dc_product.weight}" if dc_product.weight
    properties << "add_info: #{dc_product.add_info}" if dc_product.add_info

    # N.B. Needed for prebid
    properties << "shipping_weight: #{dc_product.packaging.weight}" if dc_product.packaging.weight
    properties << "shipping_dimensions: #{dc_product.packaging.dimensions}" if dc_product.packaging.dimensions
    properties << "shipping_quantity: #{dc_product.packaging.quantity}" if dc_product.packaging.quantity

    properties.each do |property|
      property_vals = property.split(':')
      px_product.set_property(property_vals[0].strip.humanize, property_vals[1].strip)
    end

    Spree::ColorProduct.where(
      product_id: px_product.id,
      color: px_product.supplier_display_name
    ).first_or_create

    # Image
    dc_product.load_image supplier_item_guid

    Rails.logger.debug("PLOAD: Loading #{dc_product.categories.count} categories")
    dc_product.categories.each do |category|
      begin
        taxon = Spree::Taxon.where(guid: category.guid).first

        Spree::Classification.where(
          taxon_id: taxon.id,
          product_id: px_product.id).first_or_create

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
      if option.type = 'Decoration Information'
        option_detail = Spree::DcOptionDetail.retrieve(option.guid)

        next if /Embroidery|Additional|Proof/ =~ option_detail.name
        next if /Drop Shipment/ =~ option_detail.name

        if option_detail.name == 'Product Color'
          option_detail.option_choices.each do |option_choice|
            Spree::ColorProduct.where(
              product_id: px_product.id,
              color: option_choice.name
            ).first_or_create
          end
          next
        end

        # Imprint Methods
        imprint_method = Spree::ImprintMethod.where(
          name: option_detail.name
        ).first_or_create

        option_detail.option_choices.each do |option_choice|
          pantone = option_choice.name.scan(/\((.*?)\)/)[0]
          pantone ||= ''

          names = option_choice.name.scan(/(.*?)\(/)
          name = ''
          name = names[0][0].strip if names.count > 0

          pms_color = Spree::PmsColor.where(
            name: name,
            pantone: pantone,
            hex: "##{option_choice.hex_num}"
          ).first_or_create

          Spree::PmsColorsSupplier.where(
            pms_color_id: pms_color.id,
            display_name: pantone,
            supplier_id: px_product.supplier_id,
            imprint_method_id: imprint_method.id
          ).first_or_create

          Spree::ImprintMethodsProduct.where(
            imprint_method_id: imprint_method.id,
            product_id: px_product.id
          ).first_or_create
        end
      else
        Rails.logger.warn("PLOAD: *** Unseen option type [#{option.type}]")
      end
    end

    # :imprint_areas,
    # :packaging
    elapsed = (Time.zone.now - beginning_time) * 1000
    Rails.logger.info("PLOAD: [#{supplier_item_guid}] Load took: #{elapsed.round(3)}ms")
  rescue StandardError => e
    Rails.logger.error("PLOAD: Failed to load [#{supplier_item_guid}] Reason: #{e.message}")
  end
end
