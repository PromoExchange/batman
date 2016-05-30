require 'csv'
require 'open-uri'
require './lib/product_loader'

def add_upcharges(product)
  Spree::UpchargeProduct.where(product: product).destroy_all
  # upcharges
  setup = Spree::UpchargeType.where(name: 'setup').first
  run = Spree::UpchargeType.where(name: 'additional_color_run').first

  screen_print = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  laser_engraving = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
  embroidery = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  four_color_process = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create

  [
    { imprint_method: screen_print, upcharge: setup, value: '50', range: '' },
    { imprint_method: screen_print, upcharge: run, value: '0.12', range: '1+' },
    { imprint_method: laser_engraving, upcharge: setup, value: '20', range: '' },
    { imprint_method: laser_engraving, upcharge: run, value: '0.12', range: '1+' },
    { imprint_method: embroidery, upcharge: setup, value: '30', range: '' },
    { imprint_method: embroidery, upcharge: run, value: '1.0', range: '1+' },
    { imprint_method: four_color_process, upcharge: setup, value: '30', range: '' },
    { imprint_method: four_color_process, upcharge: run, value: '1.0', range: '1+' },
  ].each do |charge|
    ProductLoader.add_charge(
      product: product,
      imprint_method: charge[:imprint_method],
      upcharge_type: charge[:upcharge],
      value: charge[:value],
      range: charge[:range],
      price_code: 'G',
      position: 0
    )
  end
end

puts 'Loading Fields products'

supplier = Spree::Supplier.where(dc_acct_num: '100156')

file_name = File.join(Rails.root, 'db/product_data/fields.csv')
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

  product = Spree::Product.joins(:master)
    .where(supplier: supplier)
    .where("spree_variants.sku='#{hashed[:productcode]}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{hashed[:productcode]}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:carton_weight_lbs]
  product.carton.quantity = hashed[:units_per_carton]
  product.carton.originating_zip = hashed[:fob].delete(' ').split('|')[0]
  product.carton.length = hashed[:carton_length]
  product.carton.width = hashed[:carton_width]
  product.carton.height = hashed[:carton_height]

  if product.carton.active?
    product.carton.save!
    updated_carton_count += 1
  else
    invalid_carton_count += 1
  end

  add_upcharges(product)
  updated_upcharge_count += 1

  # Product Color
  unless hashed[:colors].blank?
    colors = hashed[:colors].split(',')
    colors.each do |color|
      bits = color.split('(')
      Spree::ColorProduct.where(product: product, color: bits[0].strip ).first_or_create
    end
    updated_main_color += 1
  end

  # Imprint methods
  imprints = []
  imprints << hashed[:imprint_method_1]
  imprints << hashed[:imprint_method_2]

  was_updated = false

  imprints.each do |imprint|
    next if imprint.blank?
    if imprint == 'Silkscreen'
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    elsif imprint == 'Silkscreen and Laser Engraved'
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
      imprints << 'Lasered'
    elsif imprint == 'Woven'
      imprint_method = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
    elsif imprint == 'Lasered'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint == 'Laser'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint == 'Laser Engraved'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint == 'Embroidery'
      imprint_method = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
    elsif imprint == 'Four Color Process'
      imprint_method = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
    elsif imprint == 'Die Cut'
      imprint_method = Spree::ImprintMethod.where(name: 'Die Cut').first_or_create
    else
      fail "*****Failed to see [#{imprint}]"
    end
    unless imprint_method.nil?
      Spree::ImprintMethodsProduct.where(
        imprint_method: imprint_method,
        product: product
      ).first_or_create
      was_updated = true
    end
  end

  updated_imprint += 1 if was_updated

  product.loading
  product.check_validity!
  product.loaded! if product.state == 'loading'
end

# Add upcharges to those remaining
in_db_only = Spree::Product.where(supplier: supplier).where.not(id: found_ids).count

Spree::Product.where(supplier: supplier).where.not(id: found_ids).each do |prod|
  add_upcharges(prod)
  updated_upcharge_count += 1
end

num_invalid_after = Spree::Product.where(supplier: supplier, state: :invalid).count

puts "Products in XML: #{in_file_count}"
puts "Products in DB: #{db_product_count}"
puts "Products in XML AND DB: #{found_ids.count}"
puts "Products in XML only: #{db_load_fail}"
puts "Products in DB only: #{in_db_only}"
puts "Products with invalid cartons: #{invalid_carton_count}"
puts "Products updated with carton: #{updated_carton_count}"
puts "Products updated with upcharges: #{updated_upcharge_count}"
puts "Product main color updates: #{updated_main_color}"
puts "Product imprint methods updates: #{updated_imprint}"
puts "Products invalid before: #{num_invalid_before}"
puts "Products invalid after: #{num_invalid_after}"
