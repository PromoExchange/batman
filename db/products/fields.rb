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

file_name = File.join(Rails.root, 'db/product_data/fields.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:price1_1] && hashed[:quantity1_1]

  product_attrs = {
    sku: hashed[:productcode],
    name: hashed[:productname],
    description: hashed[:productdescription],
    price: 0
  }

  begin
    product = Spree::Product.create!(default_attrs.merge(product_attrs))
  rescue => e
    ap "Error in #{hashed[:item_sku]} product data: #{e}"
  end

  # Prices
  if hashed[:price6_1]
    price_quantity = 6
  elsif hashed[:price5_1]
    price_quantity = 5
  elsif hashed[:price4_1]
    price_quantity = 4
  elsif hashed[:price3_1]
    price_quantity = 3
  elsif hashed[:price2_1]
    price_quantity = 2
  elsif hashed[:price1_1]
    price_quantity = 1
  end
  (1..price_quantity).each do |i|
    quantity_key1 = "quantity#{i}_1".to_sym
    quantity_key2 = "quantity#{i + 1}_1".to_sym
    price_key = "price#{i}_1".to_sym

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

  # Properties
  properties = []
  properties << "Imprint Area:#{hashed[:imprint_area]}" if hashed[:imprint_area]

  properties.each do |property|
    property_vals = property.split(':')
    product.set_property(property_vals[0].strip, property_vals[1].strip)
  end
end