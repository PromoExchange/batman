require 'csv'
require 'open-uri'
require 'work_queue'
require 'thread'

puts 'Loading Primeline products'

def get_last_break(hashed, root, limit)
  highest = 0
  (1..limit).each do |i|
    price_key = "#{root}#{i}".to_sym
    highest = i unless hashed[price_key].to_i == 0
  end
  highest
end

supplier = Spree::Supplier.where(name: 'Primeline').first_or_create

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/primeline.csv')
load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

semaphore = Mutex.new

category_hash = CSV.read(File.join(Rails.root, 'db/product_data/primeline_category_map.csv')).to_h

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  count += 1
  wq.enqueue_b do
    begin
      # Skip conditionals
      next unless hashed[:price_break1] && hashed[:qty_break1]

      product_attrs = {
        sku: hashed[:productitem],
        name: hashed[:description],
        description: hashed[:romance_copy],
        price: 0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Image
      if Rails.configuration.x.load_images
        if hashed[:image_path]
          begin
            Spree::Image.create(attachment: URI.parse(hashed[:image_path]), viewable: product.master)
          rescue => e
            image_fail += 1
            ap "Error in #{hashed[:productitem]} image load: #{e}"
          end
        end
      end

      price_quantity = get_last_break(hashed, 'price_break', 5)
      next unless price_quantity > 0

      (1..price_quantity).each do |i|
        quantity_key1 = "qty_break#{i}".to_sym
        quantity_key2 = "qty_break#{i + 1}".to_sym
        price_key = "price_break#{i}".to_sym

        if i == price_quantity
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
          ap "Error in #{hashed[:productitem]} pricing data: #{e}"
        end
      end

      # Category
      category = hashed[:category]
      taxon_key = category_hash[category]

      unless taxon_key.nil?
        taxon = Spree::Taxon.where(name: taxon_key).first
        semaphore.synchronize do
          Spree::Classification.where(
            taxon_id: taxon.id,
            product_id: product.id).first_or_create
        end
      end

      # Image
      if Rails.configuration.x.load_images
        if hashed[:imagepath]
          begin
            image_uri = hashed[:imagepath]
            product.images << Spree::Image.create!(
              attachment: open(URI.parse(image_uri)),
              viewable: product)
          rescue => e
            ap "Warning: Unable to load product image [#{product_attrs[:sku]}], #{e}"
            ap "Warning: image path [#{hashed[:imagepath]}]"
            image_fail += 1
          end
        end
      end

      # Properties
      properties = []
      properties << "Size: #{hashed[:size]}" if hashed[:size]
      properties << "Colors: #{hashed[:colors]}" if hashed[:size]
      properties << "Imprint Area: #{hashed[:imprintarea]}" if hashed[:imprintarea]
      properties << "Imprint Type: #{hashed[:imprinttype]}" if hashed[:imprinttype]
      properties << "Packaging: #{hashed[:packaging]}" if hashed[:packaging]
      properties << "Notes: #{hashed[:notes]}" if hashed[:notes]
      properties << "Production Time: #{hashed[:productiontime]}" if hashed[:productiontime]
      properties << "Rush Production Time: #{hashed[:rushproductiontime]}" if hashed[:rushproductiontime]
      properties << "Discount Code: #{hashed[:discountcode]}" if hashed[:discountcode]
      properties << "Box Size Number: #{hashed[:boxsizenumber]}" if hashed[:boxsizenumber]
      properties << "Weight Per Box: #{hashed[:weightperbox]}" if hashed[:weightperbox]
      properties << "Pieces Per Box: #{hashed[:piecesperbox]}" if hashed[:piecesperbox]
      properties << "Width: #{hashed[:width]}" if hashed[:width]
      properties << "Length: #{hashed[:length]}" if hashed[:length]
      properties << "Height: #{hashed[:height]}" if hashed[:height]
      properties << "Weight: #{hashed[:weight]}" if hashed[:weight]
      properties << "Country of Origin: #{hashed[:countryorigin]}" if hashed[:countryorigin]

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in #{hashed[:productitem]} product data: #{e}"
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
