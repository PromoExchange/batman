require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading Vitronic products'

def get_last_break(hashed, root, limit)
  highest = 0
  (1..limit).each do |i|
    price_key = "#{root}#{i}".to_sym
    highest = i unless hashed[price_key].to_i == 0
  end
  highest
end

supplier = Spree::Supplier.create(name: 'Vitronic')

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/vitronic.csv')
load_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  next unless hashed[:item_name].length >= 3

  count += 1
  wq.enqueue_b do
    begin
      # Skip conditionals
      # next unless hashed[:qty_point1] && hashed[:qty_price1]

      product_attrs = {
        sku: hashed[:sku],
        name: hashed[:item_name],
        description: hashed[:product_description],
        price: 0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))
      # Properties
      properties = []
      properties << "Imprint Area:#{hashed[:imprint_area]}" if hashed[:imprint_area]

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue=> e
      load_fail += 1
      ap "Error in #{hashed[:sku]} product data: #{e}"
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end
end

# Join product threads
wq.join

last_product = 0

file_name = File.join(Rails.root, 'db/product_data/vitronic_pricing.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # We need to think about the pros/con between upcharges by IM
  # and quantity pricing. Vitronic use both but we could
  # handle it by 'internal' upcharges.
  # For now, we will only accept one set of base quanity prices
  next if hashed[:sku] == last_product
  last_product = hashed[:sku]

  begin
    product = Spree::Product.search(master_sku_eq: hashed[:sku]).result.first

    price_quantity = get_last_break(hashed, 'pricingqty', 5)
    next unless price_quantity > 0

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
        ap "Error in #{hashed[:productitem]} pricing data: #{e}"
      end
    end
  rescue=>e
    ap "Error in #{hashed[:sku]} product data: #{e}"
  ensure
    ActiveRecord::Base.clear_active_connections!
  end
end

end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Time per product: #{average_time.round(3)}ms"
