require 'csv'
require 'open-uri'

def add_charge(product, imprint_method, upcharge_type, value, range, price_code, position)
  upcharge = Spree::UpchargeProduct.where(
    product: product,
    imprint_method: imprint_method,
    upcharge_type: upcharge_type
  ).first_or_create
  upcharge.update_attributes(
    value: value,
    range: range,
    price_code: price_code,
    position: position
  )
end

def add_upcharges(product)
  # upcharges
  setup_upcharge = Spree::UpchargeType.where(name: 'setup').first
  run_upcharge = Spree::UpchargeType.where(name: 'additional_color_run').first

  Spree::UpchargeProduct.where(product: product).destroy_all

  screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  deboss_imprint = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  logomatic_imprint = Spree::ImprintMethod.where(name: 'Logomatic').first_or_create
  embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  gemphoto_imprint = Spree::ImprintMethod.where(name: 'Gemphoto').first_or_create

  add_charge(product, screen_print_imprint, setup_upcharge, '55', '', 'V', 0)
  add_charge(product, screen_print_imprint, run_upcharge, '0.99', '(6..99)', 'V', 1)
  add_charge(product, screen_print_imprint, run_upcharge, '0.74', '(100..299)', 'V', 2)
  add_charge(product, screen_print_imprint, run_upcharge, '0.59', '(300..999)', 'V', 2)
  add_charge(product, screen_print_imprint, run_upcharge, '0.45', '1000+', 'V', 4)

  add_charge(product, embroidery_imprint, run_upcharge, '2.80', '(6..99)', 'V', 1)
  add_charge(product, embroidery_imprint, run_upcharge, '2.55', '(100..299)', 'V', 2)
  add_charge(product, embroidery_imprint, run_upcharge, '2.29', '300+', 'V', 3)

  add_charge(product, deboss_imprint, setup_upcharge, '70', '', 'V', 0)

  add_charge(product, logomatic_imprint, setup_upcharge, '55', '', 'V', 0)

  add_charge(product, gemphoto_imprint, run_upcharge, '2.80', '(6..99)', 'V', 1)
  add_charge(product, gemphoto_imprint, run_upcharge, '2.55', '(100..299)', 'V', 2)
  add_charge(product, gemphoto_imprint, run_upcharge, '2.20', '(300..999)', 'V', 3)
  add_charge(product, gemphoto_imprint, run_upcharge, '2.05', '1000+', 'V', 4)
end

puts 'Loading Gemline products'

supplier = Spree::Supplier.where(dc_acct_num: '100257')

file_name = File.join(Rails.root, 'db/product_data/gemline.csv')
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
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{hashed[:item_]}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{hashed[:item_]}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:weight_per_carton_lbs]
  product.carton.quantity = hashed[:quantity_per_box]
  product.carton.originating_zip = '01843-1066'
  dimensions = hashed[:carton_dimensions].gsub(/[A-Z]/, '').delete(' ').split('x')
  product.carton.length = dimensions[0]
  product.carton.width = dimensions[1]
  product.carton.height = dimensions[2]

  if product.carton.active?
    product.carton.save!
    updated_carton_count += 1
  else
    invalid_carton_count += 1
  end

  add_upcharges(product)
  updated_upcharge_count += 1
end

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
