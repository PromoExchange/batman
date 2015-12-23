require 'csv'
require 'open-uri'

def add_charge(product, imprint_method, upcharge_type, value, range, price_code, position)
  if range.blank?
    upcharge = Spree::UpchargeProduct.where(
      product: product,
      imprint_method: imprint_method,
      upcharge_type: upcharge_type
    ).first_or_create
  else
    upcharge = Spree::UpchargeProduct.where(
      product: product,
      imprint_method: imprint_method,
      upcharge_type: upcharge_type,
      range: range
    ).first_or_create
  end
  upcharge.update_attributes(
    value: value,
    range: range,
    price_code: price_code,
    position: position
  )
end

def add_upcharges(product)

  Spree::UpchargeProduct.where(product: product).destroy_all

  # upcharges
  setup_upcharge = Spree::UpchargeType.where(name: 'setup').first
  run_upcharge = Spree::UpchargeType.where(name: 'additional_color_run').first

  screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create

  add_charge(product, screen_print_imprint, setup_upcharge, '50', '', 'V', 0)
  add_charge(product, screen_print_imprint, run_upcharge, '2.50', '(1..49)', 'V', 1)
  add_charge(product, screen_print_imprint, run_upcharge, '1.25', '(50..99)', 'V', 1)
  add_charge(product, screen_print_imprint, run_upcharge, '0.75', '(100..249)', 'V', 1)
  add_charge(product, screen_print_imprint, run_upcharge, '0.50', '(250..999)', 'V', 1)
  add_charge(product, screen_print_imprint, run_upcharge, '0.40', '1000+', 'V', 1)
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
    byebug
  end

  add_upcharges(product)
  updated_upcharge_count += 1
end

# Add upcharges to those remaining
in_db_only = Spree::Product.where(supplier: supplier).where.not(id: found_ids).count

Spree::Product.where(supplier: supplier).where.not(id: found_ids).each do |prod|
  add_upcharges(prod)
  updated_upcharge_count += 1
  if updated_upcharge_count % 10 == 0
    putc '.'
  end
end

puts "Products in XML: #{in_file_count}"
puts "Products in DB: #{db_product_count}"
puts "Products in XML AND DB: #{found_ids.count}"
puts "Products in XML only: #{db_load_fail}"
puts "Products in DB only: #{in_db_only}"
puts "Products with invalid cartons: #{invalid_carton_count}"
puts "Products updated with carton: #{updated_carton_count}"
puts "Products updated with upcharges: #{updated_upcharge_count}"
