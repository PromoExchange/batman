require 'csv'
require 'open-uri'
require 'work_queue'
require 'thread'

puts 'Loading Crown products'

supplier = Spree::Supplier.where( name: 'Crown').first_or_create

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/crown.csv')
load_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

semaphore = Mutex.new

category_hash = {
  'Tools': 'Tools',
  'Drinkware': 'Mugs-Drinkware',
  'Bags': 'Bags',
  'Workplace': 'Business Supplies',
  'Techno Trends': 'Tech-Electronics',
  'Personal Care': 'Personal-Healthcare',
  'Lifestyles': 'Sports-Outdoor',
  'Writing Instruments': 'Pens-Writing Instruments',
  'Coolers': 'Coolers'
}

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:pricingqty1] && hashed[:pricingprice1]

  count += 1;
  wq.enqueue_b do
    begin
      product_attrs = {
        sku: hashed[:item_sku],
        name: hashed[:item_name],
        description: hashed[:product_description],
        price: 1.0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Prices
      if hashed[:pricingqty5]
        price_quantity = 5
      elsif hashed[:pricingqty4]
        price_quantity = 4
      elsif hashed[:pricingqty3]
        price_quantity = 3
      elsif hashed[:pricingqty2]
        price_quantity = 2
      elsif hashed[:pricingqty1]
        price_quantity = 1
      end
      (1..price_quantity).each do |i|
        quantity_key1 = "pricingqty#{i}".to_sym
        quantity_key2 = "pricingqty#{i + 1}".to_sym
        price_key = "pricingprice#{i}".to_sym

        if i == price_quantity
          name = "#{hashed[quantity_key1]}+"
          range = "#{hashed[quantity_key1]}+"
        else
          name = "#{hashed[quantity_key1]} - #{hashed[quantity_key2]}"
          range = "(#{hashed[quantity_key1]}..#{hashed[quantity_key2]})"
        end

        begin
          Spree::VolumePrice.create!(
            variant: product.master,
            name: name,
            range: range,
            amount: hashed[price_key],
            position: i,
            discount_type: 'price'
          )
        rescue => e
          ap "Error in #{hashed[:item_sku]} pricing data: #{e}"
        end
      end

      # Categories
      product_category = hashed[:product_categories]
      categories = product_category.split(',') unless product_category.nil?

      unless categories.nil?
        categories.each do |c|
          taxon_key = category_hash[c.strip.to_sym]

          if taxon_key.nil?
            puts "Category Warning: #{hashed[:item_sku]} - #{hashed[:product_categories]}"
            next
          end

          taxon = Spree::Taxon.where(name: taxon_key).first

          if taxon.nil?
            puts "Taxon Warning: #{hashed[:item_sku]} - #{hashed[:product_categories]}"
            next
          end

          semaphore.synchronize do
            Spree::Classification.where(
              taxon_id: taxon.id,
              product_id: product.id).first_or_create
          end
        end
      end

      # Properties
      properties = []
      properties << "Imprint Area: #{hashed[:imprint_area]}" if hashed[:imprint_area]
      properties << "Packaging: #{hashed[:packaging]}" if hashed[:packaging]
      properties << "Additional Information: #{hashed[:additional_info]}" if hashed[:additional_info]
      properties << "Catalog Page: #{hashed[:catalog_page]}" if hashed[:catalog_page]
      properties << "Price Includes: #{hashed[:price_includes]}" if hashed[:price_includes]

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in #{hashed[:item_sku]} product data: #{e}"
    ensure
      ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Time per product: #{average_time.round(3)}ms"
