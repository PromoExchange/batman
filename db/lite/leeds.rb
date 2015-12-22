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
  embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  transfer_imprint = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
  deboss_imprint = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  pad_print_imprint = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
  color_print_imprint = Spree::ImprintMethod.where(name: 'Color Print').first_or_create
  photo_grafixx_imprint = Spree::ImprintMethod.where(name: 'Photografixx').first_or_create

  add_charge(product, screen_print_imprint, setup_upcharge, '44', '', 'V', 0)
  add_charge(product, screen_print_imprint, run_upcharge, '0.79', '(1..49)', 'V', 1)
  add_charge(product, screen_print_imprint, run_upcharge, '0.63', '(50..149)', 'V', 2)
  add_charge(product, screen_print_imprint, run_upcharge, '0.55', '(150..499)', 'V', 2)
  add_charge(product, screen_print_imprint, run_upcharge, '0.39', '500+', 'V', 4)

  add_charge(product, embroidery_imprint, setup_upcharge, '44', '', 'V', 0)
  add_charge(product, embroidery_imprint, run_upcharge, '2.32', '(1..49)', 'V', 1)
  add_charge(product, embroidery_imprint, run_upcharge, '2.07', '(50..149)', 'V', 2)
  add_charge(product, embroidery_imprint, run_upcharge, '1.83', '(150..499)', 'V', 2)
  add_charge(product, embroidery_imprint, run_upcharge, '1.59', '500+', 'V', 4)

  add_charge(product, transfer_imprint, setup_upcharge, '44', '', 'V', 0)
  add_charge(product, transfer_imprint, run_upcharge, '0.79', '(1..49)', 'V', 1)
  add_charge(product, transfer_imprint, run_upcharge, '0.63', '(50..149)', 'V', 2)
  add_charge(product, transfer_imprint, run_upcharge, '0.55', '(150..499)', 'V', 2)
  add_charge(product, transfer_imprint, run_upcharge, '0.39', '500+', 'V', 4)

  add_charge(product, deboss_imprint, setup_upcharge, '60', '', 'V', 0)
  add_charge(product, deboss_imprint, run_upcharge, '0.79', '(1..49)', 'V', 1)
  add_charge(product, deboss_imprint, run_upcharge, '0.63', '(50..149)', 'V', 2)
  add_charge(product, deboss_imprint, run_upcharge, '0.55', '(150..499)', 'V', 2)
  add_charge(product, deboss_imprint, run_upcharge, '0.39', '500+', 'V', 4)

  add_charge(product, pad_print_imprint, setup_upcharge, '44', '', 'V', 0)
  add_charge(product, pad_print_imprint, run_upcharge, '0.28', '(1..49)', 'V', 1)
  add_charge(product, pad_print_imprint, run_upcharge, '0.03', '(50..149)', 'V', 2)
  add_charge(product, pad_print_imprint, run_upcharge, '0.02', '(150..499)', 'V', 2)
  add_charge(product, pad_print_imprint, run_upcharge, '0.02', '500+', 'V', 4)

  add_charge(product, color_print_imprint, setup_upcharge, '44', '', 'V', 0)
  add_charge(product, color_print_imprint, run_upcharge, '0.28', '(1..49)', 'V', 1)
  add_charge(product, color_print_imprint, run_upcharge, '0.03', '(50..149)', 'V', 2)
  add_charge(product, color_print_imprint, run_upcharge, '0.02', '(150..499)', 'V', 2)
  add_charge(product, color_print_imprint, run_upcharge, '0.02', '500+', 'V', 4)

  add_charge(product, photo_grafixx_imprint, setup_upcharge, '76', '', 'V', 0)
  add_charge(product, photo_grafixx_imprint, run_upcharge, '2.39', '(1..49)', 'V', 1)
  add_charge(product, photo_grafixx_imprint, run_upcharge, '1.43', '(50..149)', 'V', 2)
  add_charge(product, photo_grafixx_imprint, run_upcharge, '1.11', '(150..499)', 'V', 2)
  add_charge(product, photo_grafixx_imprint, run_upcharge, '0.87', '500+', 'V', 4)
end

puts 'Loading Leeds products'

supplier = Spree::Supplier.where(dc_acct_num: '100306')

file_name = File.join(Rails.root, 'db/product_data/leeds.csv')
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
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{hashed[:itemno]}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{hashed[:itemno]}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:standard_master_carton_actual_weight]
  product.carton.quantity = hashed[:standard_master_carton_quantity]
  product.carton.originating_zip = '15068-7059'
  product.carton.length = hashed[:standard_master_carton_length]
  product.carton.width = hashed[:standard_master_carton_width]
  product.carton.height = hashed[:standard_master_carton_depth]

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
