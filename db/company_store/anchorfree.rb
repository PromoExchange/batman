require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading Anchor Free custom'

store_name = 'AnchorFree Company Store'

supplier = Spree::Supplier.where(name: store_name).first

fail 'Unable to find supplier' if supplier.nil?

Spree::Product.where(supplier: supplier).destroy_all

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now + 100.years
}

file_name = File.join(Rails.root, 'db/company_store_data/anchorfree.csv')

load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  count += 1
  begin
    desc = hashed[:product_description]

    product_attrs = {
      sku: hashed[:sku],
      name: hashed[:item_name],
      description: hashed[:product_description],
      price: 1.0,
      supplier_id: supplier.id
    }

    product = Spree::Product.create!(default_attrs.merge(product_attrs))

    # Image
    if Rails.configuration.x.load_images
      begin
        image_path = File.join(Rails.root, "db/product_images/anchorfree/#{product_attrs[:sku]}.jpg")
        product.images << Spree::Image.create!(
          attachment: open(image_path),
          viewable: product
        )
      rescue => e
        ap "Warning: Unable to load product image [#{product_attrs[:sku]}], #{e}"
        image_fail += 1
      end
    end

    # Main Product Color
    Spree::ColorProduct.where(product: product, color: hashed[:color]).first_or_create

    # Prices
    price_code = hashed[:pricecode]
    unless price_code.nil?
      price_code_array = Spree::Price.price_code_to_array(price_code)
      num_prices = price_code_array.size
      num_prices.times do |i|
        quantity_code = "qty" + (i+1).to_s
        price_code = "price" + (i+1).to_s
        quantity = hashed[quantity_code.to_sym]
        price = hashed[price_code.to_sym]
        byebug
        puts "Qty[#{quantity}]/Price[#{price}]"
      end
    end

  rescue => e
    load_fail += 1
    ap "Error in #{hashed[:sku]} product data: #{e}"
  ensure
    ActiveRecord::Base.clear_active_connections!
  end
end
