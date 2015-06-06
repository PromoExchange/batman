require 'csv'
require 'open-uri'

supplier = Spree::Supplier.create(name: 'Gemline')

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/gemline.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:us_min_price] && hashed[:min_qty]

  product_attrs = {
    sku: hashed[:item_],
    name: hashed[:name],
    description: hashed[:description],
    price: 0
  }

  begin
    product = Spree::Product.create!(default_attrs.merge(product_attrs))
  rescue => e
    ap "Error in #{hashed[:item_]} product data: #{e}"
    next
  end

  # Prices
  if hashed[:us_3rd_price]
    Spree::VolumePrice.create!(
      variant: product.master,
      name: "#{hashed['3rd_qty'.to_sym]}+",
      range: "#{hashed['3rd_qty'.to_sym]}+",
      amount: hashed[:us_3rd_price],
      position: 0,
      discount_type: 'price'
    )
    Spree::VolumePrice.create!(
      variant: product.master,
      name: "#{hashed['2nd_qty'.to_sym]} - #{hashed['3rd_qty'.to_sym]}",
      range: "(#{hashed['2nd_qty'.to_sym]}..#{hashed['3rd_qty'.to_sym]})",
      amount: hashed[:us_2nd_price],
      position: 0,
      discount_type: 'price'
    )
    Spree::VolumePrice.create!(
      variant: product.master,
      name: "#{hashed['min_qty'.to_sym]} - #{hashed['2nd_qty'.to_sym]}",
      range: "(#{hashed['min_qty'.to_sym]}..#{hashed['2nd_qty'.to_sym]})",
      amount: hashed[:us_min_price],
      position: 0,
      discount_type: 'price'
    )
  elsif hashed[:us_2nd_price]
    Spree::VolumePrice.create!(
      variant: product.master,
      name: "#{hashed['2nd_qty'.to_sym]}+",
      range: "#{hashed['2nd_qty'.to_sym]}+",
      amount: hashed[:us_2nd_price],
      position: 0,
      discount_type: 'price'
    )
    Spree::VolumePrice.create!(
      variant: product.master,
      name: "#{hashed['min_qty'.to_sym]} - #{hashed['2nd_qty'.to_sym]}",
      range: "(#{hashed['min_qty'.to_sym]}..#{hashed['2nd_qty'.to_sym]})",
      amount: hashed[:us_min_price],
      position: 0,
      discount_type: 'price'
    )
  else
    Spree::VolumePrice.create!(
      variant: product.master,
      name: "#{hashed['min_qty'.to_sym]}+",
      range: "#{hashed['min_qty'.to_sym]}+",
      amount: hashed[:us_min_price],
      position: 0,
      discount_type: 'price'
    )
  end

  # Properties
  properties = []
  properties << "Dimensions:#{hashed[:carton_dimensions]}" if hashed[:carton_dimensions]

  properties.each do |property|
    property_vals = property.split(':')
    product.set_property(property_vals[0].strip, property_vals[1].strip)
  end
end
