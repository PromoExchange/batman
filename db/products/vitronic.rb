require 'csv'
require 'open-uri'

# px_colors = [
#   'Black',
#   'Blue',
#   'Brown',
#   'Gold',
#   'Grey',
#   'Green',
#   'Multicolor',
#   'Orange',
#   'Pink',
#   'Purple',
#   'Red',
#   'Silver',
#   'Tan/Beige',
#   'White',
#   'Yellow'
# ]
#
# color_conversions = {}
# color_conversions_file = File.join(Rails.root, 'db/product_data/crown_color_conversion.csv')
# CSV.foreach(color_conversions_file, headers: true, header_converters: :symbol) do |row|
#   hashed = row.to_hash
#   color_conversions[hashed[:catalog_data]] = [hashed[:px_color_1], hashed[:px_color_2], hashed[:px_color_3]]
# end

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/vitronic.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  # next unless hashed[:qty_point1] && hashed[:qty_price1]

  product_attrs = {
    sku: hashed[:sku],
    name: hashed[:item_name],
    description: hashed[:product_description],
    price: 0
  }

  begin
    product = Spree::Product.create!(default_attrs.merge(product_attrs))
  rescue => e
    ap "Error in #{hashed[:sku]} product data: #{e}"
    next
  end

  # Properties
  properties = []
  properties << "Imprint Area:#{hashed[:imprint_area]}" if hashed[:imprint_area]

  properties.each do |property|
    property_vals = property.split(':')
    product.set_property(property_vals[0].strip, property_vals[1].strip)
  end
end
