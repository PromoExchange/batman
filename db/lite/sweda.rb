require 'csv'
require 'open-uri'
require './lib/product_loader'

def add_upcharges(product)
  Spree::UpchargeProduct.where(product: product).destroy_all

  setup = Spree::UpchargeType.where(name: 'setup').first
  run = Spree::UpchargeType.where(name: 'additional_color_run').first

  [
    { upcharge: setup, value: '50', range: '', position: 0 },
    { upcharge: run, value: '2.50', range: '(1..49)', position: 1 },
    { upcharge: run, value: '1.25', range: '(50..99)', position: 1 },
    { upcharge: run, value: '0.75', range: '(100..249)', position: 1 },
    { upcharge: run, value: '0.50', range: '(250..999)', position: 1 },
    { upcharge: run, value: '0.40', range: '1000+', position: 1 }
  ].each do |charge|
    ProductLoader.add_charge(
      product: product,
      imprint_method: Spree::ImprintMethod.where(name: 'Screen Print').first_or_create,
      upcharge_type: charge[:upcharge],
      value: charge[:value],
      range: charge[:range],
      price_code: 'V',
      position: charge[:position]
    )
  end
end

puts 'Loading Sweda products'

supplier = Spree::Supplier.where(dc_acct_num: '119303')

file_name = File.join(Rails.root, 'db/product_data/sweda.csv')
db_load_fail = 0
db_product_count = Spree::Product.where(supplier: supplier).count
in_file_count = 0
found_ids = []
invalid_carton_count = 0
updated_carton_count = 0
updated_upcharge_count = 0
updated_main_color = 0
updated_imprint_method = 0
num_invalid_before = Spree::Product.where(supplier: supplier, state: :invalid).count
num_invalid_after = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  sku = hashed[:sku]
  sku_parts = hashed[:sku].split('-')
  sku = sku_parts[0] if sku_parts.count > 1

  in_file_count += 1
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{sku}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{sku}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:packweight]
  product.carton.quantity = hashed[:packqty]
  product.carton.originating_zip = '91744-5159'
  product.carton.length = hashed[:packinglength]
  product.carton.width = hashed[:packingwidth]
  product.carton.height = hashed[:packingheight]

  product.carton.length = 14 if product.carton.length.blank?
  product.carton.width = 12 if product.carton.width.blank?
  product.carton.height = 12 if product.carton.height.blank?

  if product.carton.active?
    product.carton.save!
    updated_carton_count += 1
  else
    invalid_carton_count += 1
  end

  add_upcharges(product)
  updated_upcharge_count += 1

  # Product Color
  unless hashed[:colordesc].blank?
    Spree::ColorProduct.where(product: product , color: hashed[:colordesc].strip).first_or_create
    updated_main_color += 1
  end

  # Imprint Methods
  unless hashed[:note].blank?
    imprint_method = nil
    downcased_note = hashed[:note].downcase

    if /silkscreen/.match(downcased_note)
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    elsif /screen charge/.match(downcased_note)
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    elsif /stitches/.match(downcased_note)
      imprint_method = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
    elsif /heat transfer/.match(downcased_note)
      imprint_method = Spree::ImprintMethod.where(name: 'Heat Transfer').first_or_create
    elsif /epoxy dome/.match(downcased_note)
      imprint_method = Spree::ImprintMethod.where(name: 'Epoxy Dome').first_or_create
    end

    unless imprint_method.nil?
      updated_imprint_method += 1
      Spree::ImprintMethodsProduct.where(
        imprint_method: imprint_method,
        product: product
      ).first_or_create
    end
  end

  product.loading!
  product.check_validity!
  product.loaded! if product.state == 'loading'
end

# Add upcharges to those remaining
in_db_only = Spree::Product.where(supplier: supplier).where.not(id: found_ids).count

Spree::Product.where(supplier: supplier).where.not(id: found_ids).each do |prod|
  add_upcharges(prod)
  updated_upcharge_count += 1
  putc '.' if updated_upcharge_count % 10 == 0
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
puts "Products updated with main product color: #{updated_main_color}"
puts "Products updated with imprint method: #{updated_imprint_method}"
puts "Product invalid before: #{num_invalid_before}"
puts "Product invalid after: #{num_invalid_after}"
