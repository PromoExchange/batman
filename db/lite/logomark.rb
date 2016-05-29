require 'csv'
require 'open-uri'
require './lib/product_loader'

def add_upcharges(product)
  Spree::UpchargeProduct.where(product: product).destroy_all

  setup = Spree::UpchargeType.where(name: 'setup').first
  run = Spree::UpchargeType.where(name: 'additional_color_run').first

  laser_engrave = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
  value_mark = Spree::ImprintMethod.where(name: 'Valuemark').first_or_create
  logomark = Spree::ImprintMethod.where(name: 'Logomark').first_or_create
  vinyl = Spree::ImprintMethod.where(name: 'Vinyl').first_or_create
  transfer = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
  colorsplash = Spree::ImprintMethod.where(name: 'Colorsplash').first_or_create
  deboss = Spree::ImprintMethod.where(name: 'Deboss').first_or_create

  [
    { imprint_method: laser_engrave, upcharge: setup, value: '45', range: '', position: 0 },
    { imprint_method: laser_engrave, upcharge: run, value: '0.32', range: '1+', position: 1 },
    { imprint_method: value_mark, upcharge: setup, value: '45', range: '', position: 0 },
    { imprint_method: value_mark, upcharge: run, value: '0.02', range: '1+', position: 1 },
    { imprint_method: logomark, upcharge: setup, value: '50', range: '', position: 0 },
    { imprint_method: logomark, upcharge: run, value: '0.32', range: '1+', position: 1 },
    { imprint_method: vinyl, upcharge: setup, value: '45', range: '', position: 0 },
    { imprint_method: vinyl, upcharge: run, value: '0.32', range: '1+', position: 1 },
    { imprint_method: transfer, upcharge: setup, value: '45', range: '', position: 0 },
    { imprint_method: transfer, upcharge: run, value: '1', range: '1+', position: 1 },
    { imprint_method: colorsplash, upcharge: setup, value: '45', range: '', position: 0 },
    { imprint_method: colorsplash, upcharge: run, value: '0.32', range: '1+', position: 1 },
    { imprint_method: eboss, upcharge: setup, value: '80', range: '', position: 0 },
    { imprint_method: eboss, upcharge: run, value: '0.32', range: '1+', position: 1 }
  ].each do |charge|
    ProductLoader.add_charge(
      product: product,
      imprint_method: charge[:imprint_method],
      upcharge_type: charge[:upcharge],
      value: charge[:value],
      range: charge[:range],
      price_code: 'V',
      position: charge[:position]
    )
  end
end

puts 'Loading Logomark products'

supplier = Spree::Supplier.where(dc_acct_num: '101044')

file_name = File.join(Rails.root, 'db/product_data/logomark.csv')
db_load_fail = 0
db_product_count = Spree::Product.where(supplier: supplier).count
in_file_count = 0
found_ids = []
invalid_carton_count = 0
updated_carton_count = 0
updated_upcharge_count = 0
updated_main_color = 0
updated_imprint = 0
num_invalid_before = Spree::Product.where(supplier: supplier, state: :invalid).count
num_invalid_after = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  in_file_count += 1
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{hashed[:sku]}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{hashed[:sku]}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:box_weight]
  product.carton.quantity = hashed[:quantity_per_box]
  product.carton.originating_zip = '92780-6420'
  product.carton.length = hashed[:box_length]
  product.carton.width = hashed[:box_length]
  product.carton.height = hashed[:box_length]

  if product.carton.active?
    product.carton.save!
    updated_carton_count += 1
  else
    invalid_carton_count += 1
  end

  add_upcharges(product)
  updated_upcharge_count += 1

  # Product colors
  unless hashed[:item_color].blank?
    Spree::ColorProduct.where(product: product, color: hashed[:item_color] ).first_or_create
    updated_main_color += 1
  end

  # Imprints
  unless hashed[:decoration_methods].blank?
    imprints = hashed[:decoration_methods].split(',')

    imprints.each do |imprint|
      next if imprint.nil?
      if imprint.strip == 'Laser'
        imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
      elsif imprint.strip == 'Laser & Oxidation'
        imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
      elsif imprint.strip == 'Print'
        imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      elsif imprint.strip == 'Full Color Dome'
        imprint_method = Spree::ImprintMethod.where(name: 'Full Color Dome').first_or_create
      elsif imprint.strip == 'Color Splash'
        imprint_method = Spree::ImprintMethod.where(name: 'Color Splash').first_or_create
      elsif imprint.strip == 'Etched'
        imprint_method = Spree::ImprintMethod.where(name: 'Etched').first_or_create
      elsif imprint.strip == 'Etched and Color Filled'
        imprint_method = Spree::ImprintMethod.where(name: 'Etched').first_or_create
      elsif imprint.strip == 'Deboss'
        imprint_method = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
      elsif imprint.strip == 'Embroidery'
        imprint_method = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
      elsif imprint.strip == 'Full Color Transfer'
        imprint_method = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
      elsif imprint.strip == 'Custom Mold'
        imprint_method = Spree::ImprintMethod.where(name: 'Custom Mold').first_or_create
      elsif imprint.strip == 'Vinyl'
        imprint_method = Spree::ImprintMethod.where(name: 'Vinyl').first_or_create
      else
        fail "Failed to find [#{imprint.strip}]"
      end
      Spree::ImprintMethodsProduct.where(
        imprint_method: imprint_method,
        product: product
      ).first_or_create
    end
    updated_imprint += 1
  end

  product.loading
  product.check_validity!
  product.loaded! if product.state == 'loading'
end

num_invalid_after = Spree::Product.where(supplier: supplier, state: :invalid).count

# Add upcharges to those remaining
in_db_only = Spree::Product.where(supplier: supplier).where.not(id: found_ids).count

Spree::Product.where(supplier: supplier).where.not(id: found_ids).each do |prod|
  add_upcharges(prod)
  updated_upcharge_count += 1
end

puts "Products in XML: #{in_file_count}"
puts "Products in DB: #{db_product_count}"
puts "Products in XML AND DB: #{found_ids.count}"
puts "Products in XML only: #{db_load_fail}"
puts "Products in DB only: #{in_db_only}"
puts "Products with invalid cartons: #{invalid_carton_count}"
puts "Products updated with carton: #{updated_carton_count}"
puts "Products updated with upcharges: #{updated_upcharge_count}"
puts "Products updated with main color: #{updated_main_color}"
puts "Products updated with imprint method: #{updated_imprint}"
puts "Product invalid before: #{num_invalid_before}"
puts "Product invalid after: #{num_invalid_after}"
