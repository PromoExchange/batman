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

file_name = File.join(Rails.root, 'db/product_data/starline.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:price1] && hashed[:column_1_max]

  product_attrs = {
    sku: hashed[:pricecode].strip,
    name: hashed[:productname],
    description: hashed[:productdescription],
    price: 0
  }

  begin
    product = Spree::Product.create!(default_attrs.merge(product_attrs))
  rescue => e
    ap "Error in #{hashed[:pricecode]} product data: #{e}"
    next
  end

  # Image
  Spree::Image.create(attachment: URI.parse(hashed[:productimageurl]), viewable: product.master)

  # Prices
  if hashed[:price4]
    price_quantity = 4
  elsif hashed[:price3]
    price_quantity = 3
  elsif hashed[:price2]
    price_quantity = 2
  elsif hashed[:price1]
    price_quantity = 1
  end
  (1..price_quantity).each do |i|
    quantity_key1 = "column_#{i}_min".to_sym
    quantity_key2 = "column_#{i}_max".to_sym
    price_key = "price#{i}".to_sym

    if i == 1
      name = "0 - #{hashed[quantity_key2]}"
      range = "(0..#{hashed[quantity_key2]})"
    elsif i == price_quantity
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
      ap "Error in #{hashed[:pricecode]} pricing data: #{e}"
    end
  end

  # Properties
  properties = []
  properties << "Country of Origin:#{hashed[:origin]}" if hashed[:origin]

  properties.each do |property|
    property_vals = property.split(':')
    product.set_property(property_vals[0].strip, property_vals[1].strip)
  end
  exit
end
