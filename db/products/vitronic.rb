require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading Vitronic products'

Spree::Supplier.create(name: 'Vitronic')

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
        price: 0
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

wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Time per product: #{average_time.round(3)}ms"
