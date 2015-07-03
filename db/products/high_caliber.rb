require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading High Caliber products'

supplier = Spree::Supplier.where(name: 'High Caliber').first_or_create

# PMS Colors
ProductLoader.pms_load('high_caliber_pms_map.csv', supplier.id)

# Product
shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/high_caliber.csv')
load_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:qty_1] && hashed[:price_1] && hashed[:item_status] == 'Active/All Products'

  count += 1

  wq.enqueue_b do
    begin
      product_attrs = {
        sku: hashed[:hcl_item],
        name: hashed[:item_name],
        description: hashed[:description],
        price: 1.0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Prices
      if hashed[:price_5]
        price_quantity = 5
      elsif hashed[:price_4]
        price_quantity = 4
      elsif hashed[:price_3]
        price_quantity = 3
      elsif hashed[:price_2]
        price_quantity = 2
      elsif hashed[:price_1]
        price_quantity = 1
      end
      (1..price_quantity).each do |i|
        quantity_key1 = "qty_#{i}".to_sym
        quantity_key2 = "qty_#{i + 1}".to_sym
        price_key = "price_#{i}".to_sym

        if i == price_quantity
          name = "#{hashed[quantity_key1]}+"
          range = "#{hashed[quantity_key1]}+"
        else
          name = "#{hashed[quantity_key1]} - #{hashed[quantity_key2].to_i - 1}"
          range = "(#{hashed[quantity_key1]}..#{hashed[quantity_key2].to_i - 1})"
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
          ap "Error in #{hashed[:hcl_item]} pricing data: #{e}"
        end
      end

      # Properties
      properties = []
      %w(
        item_color
        item_size
        length
        width
        height
        carton_weight
        carton_qty
        standard_production_time
      ).each do |w|
        properties << "#{w.titleize}: #{hashed[w.to_sym]}" if hashed[w.to_sym]
      end

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in #{hashed[:hcl_item]} product data: #{e}"
    ensure
      ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
wq.join
end_time = Time.zone.now
average_time = ((end_time-beginning_time)/count)*1000
puts "Loaded: #{count}, Failed: #{load_fail}, Time per product: #{average_time.round(3)}ms"
