require 'csv'

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::ShippingCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/norwood_writing_instruments.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash
  binding.pry
  ap 'here'
end
