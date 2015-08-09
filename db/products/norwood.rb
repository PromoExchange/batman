# Loaded: 3017, Failed: 2893, Time per product: 1438.984ms
require 'csv'
require 'open-uri'

puts 'Loading Norwood products'

supplier = Spree::Supplier.where(name: 'Norwood').first_or_create

# PMS Colors
ProductLoader.pms_load('norwood_pms_map.csv', supplier.id)

# Product
def get_last_break(hashed, root, limit)
  highest = 0
  (1..limit).each do |i|
    key = "#{root}#{i}".to_sym
    highest = i unless hashed[key].to_i == 0
  end
  highest
end

def check_quantities(hashed, limit)
  check = true

  (1..limit).each do |i|
    quantity_key1 = "quantity#{i}".to_sym
    quantity_key2 = "quantity#{i + 1}".to_sym

    if i == 5
      range = "#{hashed[quantity_key1]}+"
      check &= (range =~ /^[0-9]+/)
    else
      range = "(#{hashed[quantity_key1]}..#{hashed[quantity_key2]})"
      check &= (range =~ /^[0-9]+\.\.[0-9]+/)
    end

    break unless check
  end
  check
end

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/norwood.csv')
load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

category_hash = CSV.read(File.join(Rails.root, 'db/product_data/norwood_category_map.csv')).to_h

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  wq.enqueue_b do
    begin
      product_attrs = {
        sku: "NORWOOD-#{hashed[:product_id]}",
        name: hashed[:product_name],
        description: hashed[:product_description],
        price: hashed[:price1],
        supplier_id: supplier.id
      }

      next unless hashed[:product_name].parameterize.length > 3

      # throw "No price found" unless hashed[:price1]
      next unless hashed[:price1]

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Category
      category = hashed[:category]
      taxon_key = category_hash[category]

      taxon = Spree::Taxon.where(name: taxon_key).first unless taxon_key.nil?

      if taxon.nil?
        puts "Taxon Warning: #{hashed[:itemno]} - #{hashed[:category]}"
      else
        Spree::Classification.where(
          taxon_id: taxon.id,
          product_id: product.id).create
      end

      # Image
      if Rails.configuration.x.load_images
        begin
          image_uri = hashed[:large_image_url]
          product.images << Spree::Image.create!(
            attachment: open(URI.parse(image_uri)),
            viewable: product)
        rescue => e
          ap "Error loading product image [#{product_attrs[:sku]}], #{e}"
        end
      end

      # Prices
      price_quantity = get_last_break(hashed, 'quantity', 5)

      next unless check_quantities(hashed, price_quantity)
      (1..price_quantity).each do |i|
        quantity_key1 = "quantity#{i}".to_sym
        quantity_key2 = "quantity#{i + 1}".to_sym
        price_key = "price#{i}".to_sym
        if i == 5
          name = "#{hashed[quantity_key1]}+"
          range = "#{hashed[quantity_key1]}+"
        else
          name = "#{hashed[quantity_key1]} - #{hashed[quantity_key2].to_i - 1}"
          range = "(#{hashed[quantity_key1]}..#{hashed[quantity_key2].to_i - 1})"
        end

        Spree::VolumePrice.create!(
          variant: product.master,
          name: name,
          range: range,
          amount: hashed[price_key],
          position: i,
          discount_type: 'price'
        )
      end

      # Properties
      properties = []
      %w(
        brand
        brand_name
        price_includes
        country_of_origin
        features
        material
        page_number
        price_message
        pack_size
        pack_weight
        unit_of_measure
        sizes
        lead_time
        rush_lead_time
        selections
        item_color_charges
        additional_product_information
      ).each do |w|
        properties << "#{w.titleize}: #{hashed[w.to_sym]}" if hashed[w.to_sym]
      end

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0], property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in NORWOOD-#{hashed[:product_id]} product data: #{e}"
    ensure
      ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
      ActiveRecord::Base.clear_active_connections!
    end
  end
  count += 1
end
wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Image fail #{image_fail}"
puts "Time per product: #{average_time.round(3)}ms"
