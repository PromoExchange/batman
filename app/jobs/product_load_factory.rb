module ProductLoadFactory
  @queue = :product_load_factory

  def self.perform(params)
    factory_name = params['name']
    dc_acct_num = params['dc_acct_num']
    Rails.logger.info("PLOAD: Factory loading #{factory_name}/#{dc_acct_num}")

    supplier = Spree::Supplier.where(dc_acct_num: dc_acct_num).first_or_create(name: factory_name)
    supplier.update_attributes(name: factory_name)

    DistributorCentral::Product.product_list(factory_name).each do |product|
      begin
        Rails.logger.info("PLOAD: Product queueing #{product.item_name}/#{product.supplier_item_num}")
        product = Spree::Product.where(supplier_item_guid: product.supplier_item_guid)
          .first_or_create(
            sku: product.supplier_item_num,
            name: product.item_name.titleize,
            price: 1.0,
            supplier: supplier
          )

        product.update_attributes!(
          available_on: Time.zone.now + 100.years,
          max_retail: product.max_retail,
          min_qty: product.min_qty,
          min_retail: product.min_retail,
          production_time: product.production_time,
          rush_available: product.rush_available,
          shipping_category: Spree::ShippingCategory.find_by_name!('Default'),
          supplier_display_name: product.supplier_display_name,
          supplier_display_num: product.supplier_display_num,
          supplier_item_num: product.supplier_item_num,
          supplier_item_guid: product.supplier_item_guid,
          tax_category: Spree::TaxCategory.find_by_name!('Default')
        )
        product.loading! unless p.state == 'loading'

        Resque.enqueue(ProductLoad, supplier_item_guid: product.supplier_item_guid)
      rescue e
        Rails.logger.error("PLOAD: Failed to load product SKU:#{product.supplier_item_num}: Reason: #{e.message}")
      end
    end
  rescue e
    Rails.logger.error("PLOAD: Failed to load #{factory_name}/#{dc_acct_num}: Reason: #{e.message}")
  end
end
