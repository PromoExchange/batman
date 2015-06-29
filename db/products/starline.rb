require 'csv'
require 'open-uri'
require 'work_queue'
require 'thread'

puts 'Loading Starline products'

supplier = Spree::Supplier.where(name: 'Starline').first_or_create

# PMS Colors
ProductLoader.pms_load('starline_pms_colors.csv', supplier.id)

# Product
shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/starline.csv')
load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

semaphore = Mutex.new

category_hash = CSV.read(File.join(Rails.root, 'db/product_data/starline_category_map.csv')).to_h

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  count += 1
  wq.enqueue_b do
    begin
      # Skip conditionals
      next unless hashed[:price1] && hashed[:column_1_max]

      # Product
      product_attrs = {
        sku: hashed[:productcode].strip,
        name: hashed[:productname],
        description: hashed[:productdescription],
        price: 1.0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Image
      if Rails.configuration.x.load_images
        if hashed[:productimageurl]
          begin
            Spree::Image.create(attachment: URI.parse(hashed[:productimageurl]), viewable: product.master)
          rescue => e
            ap "Error in #{hashed[:productcode]} image load: #{e}"
            image_fail += 1
          end
        end
      end

      # Category
      sub_category = hashed[:subcategory]
      taxon_key = category_hash[sub_category]

      unless taxon_key.nil?
        taxon = Spree::Taxon.where(name: taxon_key).first
        semaphore.synchronize do
          Spree::Classification.where(
            taxon_id: taxon.id,
            product_id: product.id).first_or_create
        end
      end

      # Prices
      if hashed[:price4]
        price_quantity = 4
      elsif hashed[:price3]
        price_quantity = 3
      elsif hashed[:price2]
        price_quantity = 2
      elsif hashed[:price1]
        price_quantity = 1
      end
      (1..price_quantity).each do |i|
        quantity_key1 = "column_#{i}_min".to_sym
        quantity_key2 = "column_#{i}_max".to_sym
        price_key = "price#{i}".to_sym

        if i == 1
          name = "0 - #{hashed[quantity_key2]}"
          range = "(0..#{hashed[quantity_key2]})"
        elsif i == price_quantity
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
          ap "Error in #{hashed[:pricecode]} pricing data: #{e}"
        end
      end

      # Properties
      properties = []
      properties << "Country of Origin: #{hashed[:origin]}" if hashed[:origin]
      properties << "Year introduced: #{hashed[:year_new]}" if hashed[:year_new]
      properties << "Is Green: #{hashed[:isgreen]}" if hashed[:isgreen]
      properties << "Packaging: #{hashed[:packaging]}" if hashed[:packaging]
      properties << "Product colors: #{hashed[:productcolors]}" if hashed[:productcolors]
      properties << "Imprint Area: #{hashed[:primary_imprint_area]}" if hashed[:primary_imprint_area]
      properties << "Imprint Method: #{hashed[:primary_imprint_method]}" if hashed[:primary_imprint_method]
      properties << "Imprint Location: #{hashed[:primary_imprint_location]}" if hashed[:primary_imprint_location]
      properties << "Imprint Height: #{hashed[:primary_imprint_height]}" if hashed[:primary_imprint_height]
      properties << "Imprint Width: #{hashed[:primary_imprint_width]}" if hashed[:primary_imprint_width]
      properties << "Minimum: #{hashed[:minimum]}" if hashed[:minimum]

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in #{hashed[:productcode]} product data: #{e}"
    ensure
      ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Image fail #{image_fail}"
puts "Time per product: #{average_time.round(3)}ms"
