require 'csv'
require 'open-uri'

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/norwood_writing_instruments.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash
  product_attrs = {
    sku: "NORWOOD-#{hashed[:product_id]}",
    name: hashed[:product_name],
    description: hashed[:product_description],
    price: hashed[:price1]
  }
  product = Spree::Product.create!(default_attrs.merge(product_attrs))
  Spree::Image.create(attachment: URI.parse(hashed[:zoom_image_url]), viewable: product.master)
  exit
end
