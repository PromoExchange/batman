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
        Rails.logger.warn("Warning: Unable to load product image [#{supplier_item_guid}], #{e.message}")
      end
    end

    # :prices,
    # :options,
    # :categories,
    # :imprint_areas,
    # :packaging

  rescue StandardError => e
    Rails.logger.error("PLOAD: Failed to load [#{supplier_item_guid}] Reason: #{e.message}")
  end
end
