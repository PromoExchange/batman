require 'csv'
require 'open-uri'
require 'work_queue'
require 'thread'

puts 'Loading Logomark products'

supplier = Spree::Supplier.where(name: 'Logomark').first_or_create

# PMS Colors
ProductLoader.pms_load('logomark_pms_map.csv', supplier.id)

# Product
shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

def check_price(price)
  price.present? && price.to_f != 0.0
end

file_name = File.join(Rails.root, 'db/product_data/logomark.csv')
load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

semaphore = Mutex.new

category_hash = CSV.read(File.join(Rails.root, 'db/product_data/logomark_category_map.csv')).to_h

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:pricepoint1qty] && hashed[:pricepoint1price]

  count += 1

  wq.enqueue_b do
    begin
      # Check prices first, no valid price = do not create product
      if check_price(hashed[:pricepoint6price])
        price_quantity = 6
      elsif check_price(hashed[:pricepoint5price])
        price_quantity = 5
      elsif check_price(hashed[:pricepoint4price])
        price_quantity = 4
      elsif check_price(hashed[:pricepoint3price])
        price_quantity = 3
      elsif check_price(hashed[:pricepoint2price])
        price_quantity = 2
      elsif check_price(hashed[:pricepoint1price])
        price_quantity = 1
      else
        fail "No pricing data"
      end

      product_attrs = {
        sku: hashed[:sku],
        name: hashed[:description],
        description: hashed[:features],
        price: 1.0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Prices
      (1..price_quantity).each do |i|
        quantity_key1 = "pricepoint#{i}qty".to_sym
        quantity_key2 = "pricepoint#{i + 1}qty".to_sym
        price_key = "pricepoint#{i}price".to_sym

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
          ap "Error in #{hashed[:sku]} pricing data: #{e}"
          ap range
          ap hashed[:pricepoint6qty]
          ap hashed[:pricepoint5qty]
          ap hashed[:pricepoint4qty]
          ap hashed[:pricepoint3qty]
          ap hashed[:pricepoint2qty]
          ap hashed[:pricepoint1qty]
        end
      end

      # Category
      category_list = hashed[:categories]
      unless category_list.nil?
        category_list.split(',').each do |c|
          taxon_key = category_hash[c.strip]
          taxon = Spree::Taxon.where(name: taxon_key).first unless taxon_key.nil?
          unless taxon.nil?
            semaphore.synchronize do
              Spree::Classification.where(
                taxon_id: taxon.id,
                product_id: product.id).first_or_create
            end
          end
        end
      end

      # Images
      if Rails.configuration.x.load_images
        begin
          image_base = hashed[:sku].match(/..[0-9]*/)
          image_uri = "http://www.logomark.com/Image/Group/Group270/#{image_base}.jpg"
          product.images << Spree::Image.create!(
            attachment: open(URI.parse(image_uri)),
            viewable: product)
        rescue => e
          ap "Warning: Unable to load product image [#{product_attrs[:sku]}], #{e}"
          image_fail += 1
        end
      end

      # Properties
      properties = []

      properties = []
      %w(
        product_line
        item_color
        features
        finish__material
        decoration_methods
        item_size
        catalog_page
        quantity_per_box
        production_time
      ).each do |w|
        properties << "#{w.titleize}: #{hashed[w.to_sym]}" if hashed[w.to_sym]
      end

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
wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Image Fails #{image_fail}"
puts "Time per product: #{average_time.round(3)}ms"
