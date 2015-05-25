require 'csv'

shipping_category = Spree::ShippingCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  available_on: Time.zone.now
}

Spree::Product.create!(default_attrs.merge(product_attrs))
