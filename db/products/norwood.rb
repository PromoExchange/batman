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
# color_conversions_file = File.join(Rails.root, 'db/product_data/norwood_color_conversion.csv')
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

file_name = File.join(Rails.root, 'db/product_data/norwood.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product_attrs = {
    sku: "NORWOOD-#{hashed[:product_id]}",
    name: hashed[:product_name],
    description: hashed[:product_description],
    price: hashed[:price1]
  }

  product = Spree::Product.create!(default_attrs.merge(product_attrs))

  # Image
  Spree::Image.create(attachment: URI.parse(hashed[:large_image_url]), viewable: product.master)

  # Prices
  (1..5).each do |i|
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
  exit
end
