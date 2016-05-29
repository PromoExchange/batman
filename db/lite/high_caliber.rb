require 'csv'
require 'open-uri'
require './lib/product_loader'

def add_upcharges(product)
  Spree::UpchargeProduct.where(product: product).destroy_all
  setup = Spree::UpchargeType.where(name: 'setup').first
  run = Spree::UpchargeType.where(name: 'additional_color_run').first
  screen_print = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create

  [
    { imprint_method: screen_print, upcharge: setup, value: '50', range: '', position: 0 },
    { imprint_method: creen_print, upcharge: run, value: '0.39', range: '1+', position: 1 }
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

puts 'Loading High Caliber products'

supplier = Spree::Supplier.where(dc_acct_num: '100652')

file_name = File.join(Rails.root, 'db/product_data/high_caliber.csv')
db_load_fail = 0
db_product_count = Spree::Product.where(supplier: supplier).count
in_file_count = 0
found_ids = []
invalid_carton_count = 0
updated_carton_count = 0
updated_upcharge_count = 0
updated_main_color = 0

num_invalid_before = Spree::Product.where(supplier: supplier, state: :invalid).count
num_invalid_after = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  sku = hashed[:hcl_item]

  in_file_count += 1
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{sku}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{sku}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:carton_weight]
  product.carton.quantity = hashed[:carton_qty]
  product.carton.originating_zip = '91702-3208'
  product.carton.length = hashed[:length]
  product.carton.width = hashed[:width]
  product.carton.height = hashed[:height]

  if product.carton.active?
    product.carton.save!
    updated_carton_count += 1
  else
    invalid_carton_count += 1
  end

  add_upcharges(product)
  updated_upcharge_count += 1

  # Product color
  unless hashed[:item_color].blank?
    colors = hashed[:item_color].split(',')
    colors.each do |color|
      Spree::ColorProduct.where(product: product, color: color.strip ).first_or_create
    end
    updated_main_color += 1
  end

  # Give everyone screenprint
  screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  Spree::ImprintMethodsProduct.where(
    imprint_method: screen_print_imprint,
    product: product
  ).first_or_create

  product.loading
  product.check_validity!
  product.loaded! if product.state == 'loading'
end

in_db_only = Spree::Product.where(supplier: supplier).where.not(id: found_ids).count

num_invalid_after = Spree::Product.where(supplier: supplier, state: :invalid).count

puts "Products in XML: #{in_file_count}"
puts "Products in DB: #{db_product_count}"
puts "Products in XML AND DB: #{found_ids.count}"
puts "Products in XML only: #{db_load_fail}"
puts "Products in DB only: #{in_db_only}"
puts "Products with invalid cartons: #{invalid_carton_count}"
puts "Products updated with carton: #{updated_carton_count}"
puts "Upcharges added: #{updated_upcharge_count}"
puts "Products updated with main product color: #{updated_main_color}"
puts "Products invalid before: #{num_invalid_before}"
puts "Products invalid after: #{num_invalid_after}"
