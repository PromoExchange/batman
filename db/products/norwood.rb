# Loaded: 3017, Failed: 2893, Time per product: 1438.984ms
require 'csv'
require 'open-uri'

puts 'Loading Norwood products'

def get_last_break(hashed, root, limit)
  highest = 0
  (1..limit).each do |i|
    key = "#{root}#{i}".to_sym
    highest = i unless hashed[key].to_i == 0
  end
  highest
end

# TODO: Merge with method above, part of larger restructure
def check_quantities(hashed, limit)
  check = true

  (1..limit).each do |i|
    quantity_key1 = "quantity#{i}".to_sym
    quantity_key2 = "quantity#{i + 1}".to_sym

    if i == 5
      range = "#{hashed[quantity_key1]}+"
      check &= (range =~ /^[0-9]+/)
    else
      range = "(#{hashed[quantity_key1]}..#{hashed[quantity_key2]})"
      check &= (range =~ /^[0-9]+\.\.[0-9]+/)
    end

    break unless check
  end
  check
end

supplier = Spree::Supplier.create(name: 'Norwood')

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/norwood.csv')
load_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  wq.enqueue_b do
    begin
      product_attrs = {
        sku: "NORWOOD-#{hashed[:product_id]}",
        name: hashed[:product_name],
        description: hashed[:product_description],
        price: hashed[:price1],
        supplier_id: supplier.id
      }

      next unless hashed[:product_name].parameterize.length > 3

      # throw "No price found" unless hashed[:price1]
      next unless hashed[:price1]

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Image
      if Rails.configuration.x.load_images
        begin
          Spree::Image.create(attachment: URI.parse(hashed[:large_image_url]), viewable: product.master)
        rescue => e
          ap "Error loading product image [#{product_attrs[:sku]}], #{e}"
        end
      end

      price_quantity = get_last_break(hashed, 'quantity', 5)

      # throw "No price found" unless check_quantities(hashed, price_quantity)
      next unless check_quantities(hashed, price_quantity)

      # Prices
      (1..price_quantity).each do |i|
        quantity_key1 = "quantity#{i}".to_sym
        quantity_key2 = "quantity#{i + 1}".to_sym
        price_key = "price#{i}".to_sym
        if i == 5
          name = "#{hashed[quantity_key1]}+"
          range = "#{hashed[quantity_key1]}+"
        else
          name = "#{hashed[quantity_key1]} - #{hashed[quantity_key2]}"
          range = "(#{hashed[quantity_key1]}..#{hashed[quantity_key2]})"
        end

        Spree::VolumePrice.create!(
          variant: product.master,
          name: name,
          range: range,
          amount: hashed[price_key],
          position: i,
          discount_type: 'price'
        )
      end

      # Properties
      properties = ["Material: #{hashed[:material]}", "Size: #{hashed[:sizes]}"].concat(hashed[:features].split('|'))
      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0], property_vals[1].strip)
      end
    rescue => e
      load_fail += 1

      ap "Error in NORWOOD-#{hashed[:product_id]} product data: #{e}"
      exit
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end
  count += 1
end
wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Time per product: #{average_time.round(3)}ms"
