require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading Leeds products'

supplier = Spree::Supplier.where(name: 'Leeds').first_or_create

# PMS Colors
ProductLoader.pms_load('leeds_pms_map.csv', supplier.id)

# Product
shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/leeds.csv')
load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

category_hash = CSV.read(File.join(Rails.root, 'db/product_data/leeds_category_map.csv')).to_h

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:priceqtycol1] && hashed[:priceuscol1]

  count += 1

  wq.enqueue_b do
    begin
      product_attrs = {
        sku: hashed[:itemno],
        name: hashed[:itemname],
        description: hashed[:catalogdescription],
        price: 1.0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Category
      subcategory = hashed[:subcategory]
      taxon_key = category_hash[subcategory]

      taxon = Spree::Taxon.where(name: taxon_key).first unless taxon_key.nil?

      if taxon.nil?
        puts "Taxon Warning: #{hashed[:itemno]} - #{hashed[:subcategory]}"
      else
        Spree::Classification.where(
          taxon_id: taxon.id,
          product_id: product.id).create
      end

      # Image
      if Rails.configuration.x.load_images
        begin
          photo_feature = hashed[:photo_feature]
          unless photo_feature.nil?
            base_file = File.basename(photo_feature, File.extname(photo_feature))
            image_uri = "http://media.pcna.com/ms/?/leeds/large/#{base_file}/en"
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
      if hashed[:priceuscol5]
        price_quantity = 5
      elsif hashed[:priceuscol4]
        price_quantity = 4
      elsif hashed[:priceuscol3]
        price_quantity = 3
      elsif hashed[:priceuscol2]
        price_quantity = 2
      elsif hashed[:priceuscol1]
        price_quantity = 1
      end
      (1..price_quantity).each do |i|
        quantity_key1 = "priceqtycol#{i}".to_sym
        quantity_key2 = "priceqtycol#{i + 1}".to_sym
        price_key = "priceuscol#{i}".to_sym

        if i == price_quantity
          name = "#{hashed[quantity_key1]}+"
          range = "#{hashed[quantity_key1]}+"
        else
          name = "#{hashed[quantity_key1]} - #{hashed[quantity_key2].to_i - 1}"
          range = "(#{hashed[quantity_key1]}..#{hashed[quantity_key2].to_i - 1}"
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

      # Properties
      properties = []
      %w(
        material
        colorlist
        catalogsize
        packagingdetails
        catalogweight
        disclaimers
        standard_master_carton_width
        standard_master_carton_length
        standard_master_carton_depth
        standard_master_carton_quantity
        standard_master_carton_actual_weight
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
