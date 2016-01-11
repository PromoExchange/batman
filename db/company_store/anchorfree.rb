require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading Anchor Free custom'

store_name = 'AnchorFree Company Store'

supplier = Spree::Supplier.where(name: store_name).first

fail 'Unable to find supplier' if supplier.nil?

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now + 100.years
}

file_name = File.join(Rails.root, 'db/company_store_data/anchorfree.csv')
