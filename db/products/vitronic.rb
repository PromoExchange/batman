require 'csv'
require 'open-uri'
require 'work_queue'
require 'thread'

puts 'Loading Vitronic products'

supplier = Spree::Supplier.where(name: 'Vitronic').first_or_create

# PMS Colors
ProductLoader.pms_load('vitronic_pms_colors.csv', supplier.id)

# Products
shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/vitronic.csv')
load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

semaphore = Mutex.new

category_map = {
  'Headwear': 'Headwear-Caps',
  'Lifestyle': 'Personal-Healthcare',
  'Totes & Bags': 'Bags-Coolers-Totes',
  'Business': 'Business Supplies',
  'Umbrellas': 'Personal Umbrellas',
  'Calendars': 'Calendars',
  'Plush': 'Stuffed Animals',
  'Andrew Philips': 'Executive' # Technically a Brand
}

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  next unless hashed[:item_name].length >= 3

  count += 1
  wq.enqueue_b do
    begin
      desc = hashed[:product_description]
      [
        '&bull;'
      ].each do |s|
        desc.gsub!(s, ';')
      end

      product_attrs = {
        sku: hashed[:sku],
        name: hashed[:item_name],
        description: desc,
        price: 1.0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Image
      if Rails.configuration.x.load_images
        begin
          image_uri = "http://www.vitronicpromotional.com/image.php?sz=viewitem_lg&itemno=#{hashed[:sku]}"
          product.images << Spree::Image.create!(
            attachment: open(URI.parse(image_uri)),
            viewable: product)
        rescue => e
          ap "Warning: Unable to load product image [#{product_attrs[:sku]}], #{e}"
          image_fail += 1
        end
      end

      # Main Product Color
      colors = hashed[:available_colors]
      if colors
        colors.split(',').each do |color|
          Spree::ColorProduct.create(product_id: product.id, color: color.strip)
        end
      else
        Spree::ColorProduct.create(product_id: product.id, color: 'Default')
      end

      # Categories
      product_category = hashed[:product_categories]
      categories = product_category.split(',') unless product_category.nil?

      unless categories.nil?
        categories.each do |c|
          taxon_key = category_map[c.strip.to_sym]

          if taxon_key.nil?
            puts "Category Warning: #{hashed[:sku]} - #{hashed[:product_categories]}"
            next
          end

          taxon = Spree::Taxon.where(name: taxon_key).first

          semaphore.synchronize do
            Spree::Classification.where(
              taxon_id: taxon.id,
              product_id: product.id).first_or_create
          end
        end
      end

      # Properties
      properties = []
      properties << "Country of Origin: #{hashed[:origin]}" if hashed[:origin]
      properties << "Imprint Area: #{hashed[:imprint_area]}" if hashed[:imprint_area]
      properties << "Catalog Page: #{hashed[:catalog_page]}" if hashed[:catalog_page]
      properties << "Price Includes: #{hashed[:price_includes]}" if hashed[:price_includes]
      properties << "Product Size: #{hashed[:product_size]}" if hashed[:product_size]
      properties << "Additional Info: #{hashed[:additional_info]}" if hashed[:additional_info]
      properties << "FOB: #{hashed[:fob]}" if hashed[:fob]
      properties << "Shipping Quantity: #{hashed[:shipping_quantity]}" if hashed[:shipping_quantity]
      properties << "Shipping Dimensions: #{hashed[:shipping_dimensions]}" if hashed[:shipping_dimensions]
      properties << "Available Colors: #{hashed[:available_colors]}" if hashed[:available_colors]

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in #{hashed[:sku]} product data: #{e}"
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
  end
end

# Join product threads
wq.join

# Pricing
def get_last_break(hashed, root, limit)
  highest = 0
  (1..limit).each do |i|
    price_key = "#{root}#{i}".to_sym
    highest = i unless hashed[price_key].to_i == 0
  end
  highest
end

last_product = 0

file_name = File.join(Rails.root, 'db/product_data/vitronic_pricing.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash


  begin
    product = Spree::Product.search(master_sku_eq: hashed[:sku]).result.first

    fail 'Failed to find product' unless product

    # Imprint methods
    imprint_method = hashed[:imprint_method]
    [
      ['Image Lock', 'Image Lock'],
      ['Embroidery', 'Embroidery'],
      ['Vivid Expression', 'Vivid Expression'],
      ['Screen Print', 'Screen Print'],
      ['ScreenPrint', 'Screen Print'],
      ['Photo Magic', 'Photo Magic'],
      ['Deboss', 'Deboss'],
      ['Four Color Process', 'Four Color Process'],
      ['Hot Stamp', 'Hot Stamp'],
      ['Full Color', 'Full Color'],
      ['Photo Magic', 'Photo Magic'],
      ['Blank', 'Blank']
    ].each do |w|
      if( imprint_method.include?(w[0]))
        imprint = Spree::ImprintMethod.where(name: w[1]).first
        unless imprint.nil?
          Spree::ImprintMethodsProduct.create(
            imprint_method_id: imprint.id,
            product_id: product.id)
        end
      end
    end

    # We need to think about the pros/cons between upcharges by IM
    # and quantity pricing. Vitronic use both but we could
    # handle it by 'internal' upcharges.
    # For now, we will only accept one set of base quantity prices
    next if hashed[:sku] == last_product
    last_product = hashed[:sku]

    # Price
    price_quantity = get_last_break(hashed, 'pricingqty', 5)

    fail 'No pricing data' unless price_quantity > 0

    (1..price_quantity).each do |i|
      quantity_key1 = "pricingqty#{i}".to_sym
      quantity_key2 = "pricingqty#{i + 1}".to_sym
      price_key = "pricingprice#{i}".to_sym

      if i == price_quantity
        name = "#{hashed[quantity_key1]}+"
        range = "#{hashed[quantity_key1]}+"
      else
        name = "#{hashed[quantity_key1]} - #{hashed[quantity_key2].to_i - 1}"
        range = "(#{hashed[quantity_key1]}..#{hashed[quantity_key2].to_i - 1})"
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
        ap "Error in #{hashed[:productitem]} pricing data: #{e}"
      end
    end
  rescue => e
    ap "Error in #{hashed[:sku]} product data: #{e}"
  ensure
    ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
    ActiveRecord::Base.clear_active_connections!
  end
end
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Image fail #{image_fail}"
puts "Time per product: #{average_time.round(3)}ms"
