module ProductLoad
  @queue = :product_load

  def self.perform(params)
    supplier_item_guid = params['supplier_item_guid']
    # supplier_item_guid = params[:supplier_item_guid]
    Rails.logger.info("PLOAD: Product loading #{supplier_item_guid}")

    px_product = Spree::Product.where(supplier_item_guid: supplier_item_guid).first
    fail 'Unable to locate DB record' if px_product.nil?

    # http://www.distributorcentral.com/resources/xml/item_information.cfm?acctwebguid=F616D9EB-87B9-4B32-9275-0488A733C719&supplieritemguid=3D0F1C12-E3F6-11D3-896A-00105A7027AA

    dc_product = Spree::DC::FullProduct.retrieve(supplier_item_guid)

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
    properties.each do |property|
      property_vals = property.split(':')
      px_product.set_property(property_vals[0].strip.humanize, property_vals[1].strip)
    end

    # Image
    if Rails.configuration.x.load_images
      begin
        px_product.images.destroy
        image_uri = "http://www.distributorcentral.com/resources/productimage.cfm?Prod=#{supplier_item_guid}&size=large"
        # http://www.distributorcentral.com/resources/productimage.cfm?Prod=3D0F1C12-E3F6-11D3-896A-00105A7027AA&size=large
        px_product.images << Spree::Image.create!(
          attachment: open(URI.parse(image_uri)),
          viewable: px_product
        )
      rescue StandardError => e
        Rails.logger.warn("PLOAD: Warning: Unable to load product image [#{supplier_item_guid}], #{e.message}")
      end
    end

    # Category
    Rails.logger.info("PLOAD: Loading #{dc_product.categories.count} categories")
    dc_product.categories.each do |category|
      begin
        taxon = Spree::Taxon.where(name: category.name).first

        Spree::Classification.where(
          taxon_id: taxon.id,
          product_id: px_product.id).first_or_create

      rescue StandardError => e
        Rails.logger.warn("PLOAD: Unable to associate []#{category.name}]. Reason: #{e.message}")
      end
    end

    # Price

    # :prices,
    # :options,
    # :categories,
    # :imprint_areas,
    # :packaging

  rescue StandardError => e
    Rails.logger.error("PLOAD: Failed to load [#{supplier_item_guid}] Reason: #{e.message}")
  end
end
