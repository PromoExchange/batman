module ProductLoadFactory
  @queue = :product_load_factory

  def self.perform(params)
    factory_name = params['name']
    dc_acct_num = params['dc_acct_num']
    Rails.logger.info("PLOAD: Factory loading #{factory_name}/#{dc_acct_num}")

    supplier = Spree::Supplier.where(dc_acct_num: dc_acct_num).first

    if supplier.nil?
      supplier = Spree::Supplier.create(
        name: factory_name,
        dc_acct_num: dc_acct_num
      )
    end

    supplier.update_attributes(name: factory_name)

    shipping_category = Spree::ShippingCategory.find_by_name!('Default')
    tax_category = Spree::TaxCategory.find_by_name!('Default')

    default_attrs = {
      shipping_category: shipping_category,
      tax_category: tax_category
    }

    products = Spree::DC::BaseProduct.product_list factory_name
    products.each do |product|
      begin
        product_attrs = {
          sku: product.supplier_item_num,
          name: product.item_name,
          price: 1.0,
          supplier_id: supplier.id
        }

        Rails.logger.info("PLOAD: Product queueing #{product.item_name}/#{product.supplier_item_num}")
        p = Spree::Product.where(supplier_item_guid: product.supplier_item_guid).first
        p = Spree::Product.create!(default_attrs.merge(product_attrs)) if p.nil?

        additional_attrs = {
          available_on: Time.zone.now,
          max_retail: product.max_retail,
          min_qty: product.min_qty,
          min_retail: product.min_retail,
          production_time: product.production_time,
          rush_available: product.rush_available,
          supplier_display_name: product.supplier_display_name,
          supplier_display_num: product.supplier_display_num,
          supplier_item_num: product.supplier_item_num,
          supplier_item_guid: product.supplier_item_guid
        }
        p.update_attributes!(additional_attrs)
        p.save
        p.loading! unless p.state == 'loading'

        Resque.enqueue(
          ProductLoad,
          supplier_item_guid: product.supplier_item_guid
        )
      rescue StandardError => e
        Rails.logger.error("PLOAD: Failed to load product SKU:#{product.supplier_item_num}: Reason: #{e.message}")
      end
    end
  rescue StandardError => e
    Rails.logger.error("PLOAD: Failed to load #{factory_name}/#{dc_acct_num}: Reason: #{e.message}")
  end
end
