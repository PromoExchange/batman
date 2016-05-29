require 'csv'
require 'open-uri'
require './lib/product_loader'

def add_upcharges(product)
  Spree::UpchargeProduct.where(product: product).destroy_all

  # upcharges
  setup = Spree::UpchargeType.where(name: 'setup').first
  run = Spree::UpchargeType.where(name: 'additional_color_run').first

  screen_print = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  deboss = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  logomatic = Spree::ImprintMethod.where(name: 'Logomatic').first_or_create
  embroidery = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  gemphoto = Spree::ImprintMethod.where(name: 'Gemphoto').first_or_create

  [
    { imprint_method: screen_print, upcharge: setup, value: '55', range: '', position: 0 },
    { imprint_method: screen_print, upcharge: run, value: '0.99', range: '(6..99)', position: 1 },
    { imprint_method: screen_print, upcharge: run, value: '0.74', range: '(100..299)', position: 2 },
    { imprint_method: screen_print, upcharge: run, value: '0.59', range: '(300..999)', position: 2 },
    { imprint_method: screen_print, upcharge: run, value: '0.45', range: '1000+', position: 4 },
    { imprint_method: embroidery, upcharge: run, value: '2.8', range: '(6..99)', position: 1 },
    { imprint_method: embroidery, upcharge: run, value: '2.55', range: '(100..299)', position: 2 },
    { imprint_method: embroidery, upcharge: run, value: '2.29', range: '300+', position: 3 },
    { imprint_method: deboss, upcharge: setup, value: '70', range: '', position: 0 },
    { imprint_method: logomatic, upcharge: setup, value: '55', range: '', position: 0 },
    { imprint_method: gemphoto, upcharge: run, value: '2.8', range: '(6..99)', position: 1 },
    { imprint_method: gemphoto, upcharge: run, value: '2.55', range: '(100..299)', position: 2 },
    { imprint_method: gemphoto, upcharge: run, value: '2.2', range: '(300..999)', position: 3 },
    { imprint_method: gemphoto, upcharge: run, value: '2.05', range: '1000+', position: 4 },
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
updated_main_color = 0
updated_imprint = 0
num_invalid_before = Spree::Product.where(supplier: supplier, state: :invalid).count
num_invalid_after = 0
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

  # Product Colors
  # available_colors
  unless hashed[:color].blank?
    Spree::ColorProduct.where(product: product, color: hashed[:color] ).first_or_create
    updated_main_color += 1
  end

  was_updated_imprint = false
  # Imprint methods
  if hashed[:print].present?
    screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    Spree::ImprintMethodsProduct.where(
      imprint_method: screen_print_imprint,
      product: product
    ).first_or_create
    was_updated_imprint = true
  end

  if hashed[:embroider].present?
    embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
    Spree::ImprintMethodsProduct.where(
      imprint_method: embroidery_imprint,
      product: product
    ).first_or_create
    was_updated_imprint = true
  end

  if hashed[:logomagic].present?
    logomatic_imprint = Spree::ImprintMethod.where(name: 'Logomatic').first_or_create
    Spree::ImprintMethodsProduct.where(
      imprint_method: logomatic_imprint,
      product: product
    ).first_or_create
    was_updated_imprint = true
  end

  if hashed[:laser_engrave].present?
    laser_engraving_imprint = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    Spree::ImprintMethodsProduct.where(
      imprint_method: laser_engraving_imprint,
      product: product
    ).first_or_create
    was_updated_imprint = true
  end

  if hashed[:gemphotoheat_transfers].present?
    gemphoto_imprint = Spree::ImprintMethod.where(name: 'Gemphoto').first_or_create
    Spree::ImprintMethodsProduct.where(
      imprint_method: gemphoto_imprint,
      product: product
    ).first_or_create
    was_updated_imprint = true
  end

  if hashed[:debossemboss].present?
    deboss_imprint = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
    Spree::ImprintMethodsProduct.where(
      imprint_method: deboss_imprint,
      product: product
    ).first_or_create
    was_updated_imprint = true
  end

  updated_imprint += 1 if was_updated_imprint

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
puts "Products updated with main color: #{updated_main_color}"
puts "Products updated with imprint method: #{updated_imprint}"
puts "Product invalid before: #{num_invalid_before}"
puts "Product invalid after: #{num_invalid_after}"
