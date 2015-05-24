require 'csv'

Spree::Product.create!(name: 'hello', price: 2.99, shipping_category: Spree::ShippingCategory.find_by_name!('Default'))
