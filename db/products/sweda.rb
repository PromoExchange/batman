require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading Sweda products'

Spree::Supplier.create(name: 'Sweda')

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/sweda.csv')
load_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  next unless hashed[:qty_point1] && hashed[:qty_price1]

  count += 1

  wq.enqueue_b do
    begin
      # Skip conditionals

      product_attrs = {
        sku: hashed[:itemno],
        name: hashed[:productname],
        description: hashed[:description],
        price: 0
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Image
      # Spree::Image.create(attachment: URI.parse(hashed[:productimageurl]), viewable: product.master)

      # Prices
      if hashed[:qty_price4]
        price_quantity = 4
      elsif hashed[:qty_price3]
        price_quantity = 3
      elsif hashed[:qty_price2]
        price_quantity = 2
      elsif hashed[:qty_price1]
        price_quantity = 1
      end
      (1..price_quantity).each do |i|
        quantity_key1 = "qty_point#{i}".to_sym
        quantity_key2 = "qty_point#{i + 1}".to_sym
        price_key = "qty_price#{i}".to_sym

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
          ap "Error in #{hashed[:itemno]} pricing data: #{e}"
        end
      end

      # Properties
      properties = []
      properties << "Specification:#{hashed[:specification]}" if hashed[:specification]

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in #{hashed[:itemno]} product data: #{e}"
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Time per product: #{average_time.round(3)}ms"
