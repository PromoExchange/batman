require 'csv'
require 'open-uri'
require 'work_queue'

puts 'Loading Gemline products'

supplier = Spree::Supplier.where(name: 'Gemline').first_or_create

# PMS Colors
ProductLoader.pms_load('gemline_pms_map.csv', supplier.id)

# Products
shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now
}

file_name = File.join(Rails.root, 'db/product_data/gemline.csv')
load_fail = 0
count = 0
beginning_time = Time.zone.now
wq = WorkQueue.new 4

category_hash = CSV.read(File.join(Rails.root, 'db/product_data/gemline_category_map.csv')).to_h

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # Skip conditionals
  next unless hashed[:us_min_price] && hashed[:min_qty]

  count += 1
  wq.enqueue_b do
    begin
      product_attrs = {
        sku: "GEMLINE-#{hashed[:item_]}",
        name: hashed[:name],
        description: hashed[:description],
        price: 1.0,
        supplier_id: supplier.id
      }

      product = Spree::Product.create!(default_attrs.merge(product_attrs))

      # Category
      category_list = hashed[:category]
      unless category_list.nil?
        category_list.split(',').each do |c|
          taxon_key = category_hash[c.strip]
          # We swallow nil matches, because Gemline add themes to the categories
          taxon = Spree::Taxon.where(name: taxon_key).first unless taxon_key.nil?
          unless taxon.nil?
            Spree::Classification.where(
              taxon_id: taxon.id,
              product_id: product.id).create
          end
        end
      end

      # Prices
      if hashed[:us_3rd_price]
        Spree::VolumePrice.create!(
          variant: product.master,
          name: "#{hashed['3rd_qty'.to_sym]}+",
          range: "#{hashed['3rd_qty'.to_sym]}+",
          amount: hashed[:us_3rd_price],
          position: 0,
          discount_type: 'price'
        )
        Spree::VolumePrice.create!(
          variant: product.master,
          name: "#{hashed['2nd_qty'.to_sym]} - #{hashed['3rd_qty'.to_sym].to_i - 1}",
          range: "(#{hashed['2nd_qty'.to_sym]}..#{hashed['3rd_qty'.to_sym].to_i - 1})",
          amount: hashed[:us_2nd_price],
          position: 0,
          discount_type: 'price'
        )
        Spree::VolumePrice.create!(
          variant: product.master,
          name: "#{hashed['min_qty'.to_sym]} - #{hashed['2nd_qty'.to_sym].to_i - 1}",
          range: "(#{hashed['min_qty'.to_sym]}..#{hashed['2nd_qty'.to_sym].to_i - 1})",
          amount: hashed[:us_min_price],
          position: 0,
          discount_type: 'price'
        )
      elsif hashed[:us_2nd_price]
        Spree::VolumePrice.create!(
          variant: product.master,
          name: "#{hashed['2nd_qty'.to_sym]}+",
          range: "#{hashed['2nd_qty'.to_sym]}+",
          amount: hashed[:us_2nd_price],
          position: 0,
          discount_type: 'price'
        )
        Spree::VolumePrice.create!(
          variant: product.master,
          name: "#{hashed['min_qty'.to_sym]} - #{hashed['2nd_qty'.to_sym].to_i - 1}",
          range: "(#{hashed['min_qty'.to_sym]}..#{hashed['2nd_qty'.to_sym].to_i - 1})",
          amount: hashed[:us_min_price],
          position: 0,
          discount_type: 'price'
        )
      else
        Spree::VolumePrice.create!(
          variant: product.master,
          name: "#{hashed['min_qty'.to_sym]}+",
          range: "#{hashed['min_qty'.to_sym]}+",
          amount: hashed[:us_min_price],
          position: 0,
          discount_type: 'price'
        )
      end

      # Properties
      properties = []
      %w(
        color
        length
        height
        width
        diameter
        fabricmaterial
        code
        min_qty
        weight_per_carton_lbs
        quantity_per_box
        carton_dimensions
      ).each do |w|
        properties << "#{w.titleize}: #{hashed[w.to_sym]}" if hashed[w.to_sym]
      end

      properties.each do |property|
        property_vals = property.split(':')
        product.set_property(property_vals[0].strip, property_vals[1].strip)
      end
    rescue => e
      load_fail += 1
      ap "Error in GEMLINE-#{hashed[:item_]} product data: #{e}"
    ensure
      ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
      ActiveRecord::Base.clear_active_connections!
    end
  end
end
wq.join
end_time = Time.zone.now
average_time = ((end_time - beginning_time) / count) * 1000
puts "Loaded: #{count}, Failed: #{load_fail}, Time per product: #{average_time.round(3)}ms"
