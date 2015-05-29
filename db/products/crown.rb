require 'csv'
require 'open-uri'

px_colors = [
  'Black',
  'Blue',
  'Brown',
  'Gold',
  'Grey',
  'Green',
  'Multicolor',
  'Orange',
  'Pink',
  'Purple',
  'Red',
  'Silver',
  'Tan/Beige',
  'White',
  'Yellow'
]

color_conversions = {}
color_conversions_file = File.join(Rails.root, 'db/product_data/crown_color_conversion.csv')
CSV.foreach(color_conversions_file, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash
  color_conversions[hashed[:catalog_data]] = [hashed[:px_color_1], hashed[:px_color_2], hashed[:px_color_3]]
end

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/crown.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:pricingqty1] && hashed[:pricingprice1]

  product_attrs = {
    sku: hashed[:item_sku],
    name: hashed[:item_name],
    description: hashed[:product_description],
    price: 0
  }

  product = Spree::Product.create!(default_attrs.merge(product_attrs))

  # Image
  # Spree::Image.create(attachment: URI.parse(hashed[:large_image_url]), viewable: product.master)

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
    rescue
      binding.pry
      ap 'here'
    end
  end

  # Properties
  properties = []
  properties << "Imprint Area:#{hashed[:imprint_area]}" if hashed[:imprint_area]
  properties << "Packaging:#{hashed[:packaging]}" if hashed[:packaging]
  properties << "Additional Information:#{hashed[:additional_info]}" if hashed[:additional_info]

  properties.each do |property|
    property_vals = property.split(':')
    product.set_property(property_vals[0].strip, property_vals[1].strip)
  end
end
