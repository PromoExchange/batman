require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading Sweda products'

supplier = Spree::Supplier.where(name: 'Sweda').first_or_create

# PMS Colors
ProductLoader.pms_load('sweda_pms_map.csv', supplier.id)

# Product
shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/sweda.csv')
load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

category_hash = CSV.read(File.join(Rails.root, 'db/product_data/sweda_category_map.csv')).to_h

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  next unless hashed[:qty_point1] && hashed[:qty_price1]

  count += 1

  wq.enqueue_b do
    begin
      product_attrs = {
        sku: hashed[:sku],
        name: hashed[:productname],
        description: hashed[:description],
        price: 0
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Image
      if Rails.configuration.x.load_images
        begin
          image_file = hashed[:image]
          unless image_file.nil?
            image_uri = "http://swedausa.com/Uploads/Products/LargeImg/#{image_file}"
            product.images << Spree::Image.create!(
              attachment: open(URI.parse(image_uri)),
              viewable: product)
          end
        rescue => e
          ap "Warning: Unable to load product image [#{product_attrs[:sku]}], #{e}"
          image_fail += 1
        end
      end

      # Prices
      if hashed[:qty_point6]
        price_quantity = 6
      elsif hashed[:qty_point5]
        price_quantity = 5
      elsif hashed[:qty_point4]
        price_quantity = 4
      elsif hashed[:qty_point3]
        price_quantity = 3
      elsif hashed[:qty_point2]
        price_quantity = 2
      elsif hashed[:qty_point1]
        price_quantity = 1
      end
      (1..price_quantity).each do |i|
        quantity_key1 = "qty_point#{i}".to_sym
        quantity_key2 = "qty_point#{i + 1}".to_sym
        price_key = "qty_price#{i}".to_sym

        if i == price_quantity
          name = "#{hashed[quantity_key1]}+"
          range = "#{hashed[quantity_key1]}+"
        else
          name = "#{hashed[quantity_key1]} - #{(hashed[quantity_key2].to_i)-1})"
          range = "(#{hashed[quantity_key1]}..#{(hashed[quantity_key2].to_i)-1})"
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
          ap "Error in #{hashed[:itemno]} pricing data: #{e}"
        end
      end

      # Category
      category = hashed[:category_name]
      key = category.split(';')[0]
      taxon_key = category_hash[key]

      taxon = Spree::Taxon.where(name: taxon_key).first unless taxon_key.nil?

      # Sweda does not always categorize product, skip nils
      unless taxon.nil?
        Spree::Classification.where(
          taxon_id: taxon.id,
          product_id: product.id).create
      end

      # Properties
      properties = []
      %w(
        sizecode
        sizedesc
        colorcode
        colordesc
        grossweight
        note
        imprintarea
        packqty
        packweight
        productionmintime
        productionmaxtime
        qty_desc
      ).each do |w|
        properties << "#{w.titleize}: #{hashed[w.to_sym]}" if hashed[w.to_sym]
      end
      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in #{hashed[:itemno]} product data: #{e}"
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Image fail #{image_fail}"
puts "Time per product: #{average_time.round(3)}ms"
