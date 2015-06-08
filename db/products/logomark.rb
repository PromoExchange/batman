require 'csv'
require 'open-uri'

supplier = Spree::Supplier.create(name: 'Logomark')

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/logomark.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:pricepoint1qty] && hashed[:pricepoint1price]

  product_attrs = {
    sku: hashed[:sku],
    name: hashed[:name],
    description: hashed[:description],
    price: 0
  }

  begin
    product = Spree::Product.create!(default_attrs.merge(product_attrs))
  rescue => e
    ap "Error in #{hashed[:sku]} product data: #{e}"
    next
  end

  # Prices
  if hashed[:pricepoint6price]
    price_quantity = 6
  elsif hashed[:pricepoint5price]
    price_quantity = 5
  elsif hashed[:pricepoint4price]
    price_quantity = 4
  elsif hashed[:pricepoint3price]
    price_quantity = 3
  elsif hashed[:pricepoint2price]
    price_quantity = 2
  elsif hashed[:pricepoint1price]
    price_quantity = 1
  end
  (1..price_quantity).each do |i|
    quantity_key1 = "pricepoint#{i}qty".to_sym
    quantity_key2 = "pricepoint#{i + 1}qty".to_sym
    price_key = "pricepoint#{i}price".to_sym

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
      ap "Error in #{hashed[:sku]} pricing data: #{e}"
    end
  end

  # Properties
  properties = []
  properties << "Features:#{hashed[:features]}" if hashed[:features]
  properties << "Size:#{hashed[:item_size]}" if hashed[:item_size]

  properties.each do |property|
    property_vals = property.split(':')
    product.set_property(property_vals[0].strip, property_vals[1].strip)
  end
end
