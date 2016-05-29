require 'csv'
require 'open-uri'

def add_upcharges(product)
  Spree::UpchargeProduct.where(product: product).destroy_all

  setup = Spree::UpchargeType.where(name: 'setup').first
  run = Spree::UpchargeType.where(name: 'additional_color_run').first

  screen_print = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  embroidery = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  transfer = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
  deboss = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  pad_print = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
  color_print = Spree::ImprintMethod.where(name: 'Color Print').first_or_create
  photo_grafixx = Spree::ImprintMethod.where(name: 'Photografixx').first_or_create

  [
    { imprint_method: screen_print, upcharge: setup, value: '44', range: '', position: 0 },
    { imprint_method: screen_print, upcharge: run, value: '0.79', range: '(1..49)', position: 1 },
    { imprint_method: screen_print, upcharge: run, value: '0.63', range: '(50..149)', position: 2 },
    { imprint_method: screen_print, upcharge: run, value: '0.55', range: '(150..499)', position: 2 },
    { imprint_method: screen_print, upcharge: run, value: '0.39', range: '500+', position: 4 },
    { imprint_method: embroidery, upcharge: setup, value: '44', range: '', position: 0 },
    { imprint_method: embroidery, upcharge: run, value: '2.32', range: '(1..49)', position: 1 },
    { imprint_method: embroidery, upcharge: run, value: '2.07', range: '(50..149)', position: 2 },
    { imprint_method: embroidery, upcharge: run, value: '1.83', range: '(150..499)', position: 2 },
    { imprint_method: embroidery, upcharge: run, value: '1.59', range: '500+', position: 4 },
    { imprint_method: transfer, upcharge: setup, value: '44', range: '', position: 0 },
    { imprint_method: transfer, upcharge: run, value: '0.79', range: '(1..49)', position: 1 },
    { imprint_method: transfer, upcharge: run, value: '0.63', range: '(50..149)', position: 2 },
    { imprint_method: transfer, upcharge: run, value: '0.55', range: '(150..499)', position: 2 },
    { imprint_method: transfer, upcharge: run, value: '0.39', range: '500+', position: 4 },
    { imprint_method: eboss, upcharge: setup, value: '60', range: '', position: 0 },
    { imprint_method: eboss, upcharge: run, value: '0.79', range: '(1..49)', position: 1 },
    { imprint_method: eboss, upcharge: run, value: '0.63', range: '(50..149)', position: 2 },
    { imprint_method: eboss, upcharge: run, value: '0.55', range: '(150..499)', position: 2 },
    { imprint_method: eboss, upcharge: run, value: '0.39', range: '500+', position: 4 },
    { imprint_method: pad_print, upcharge: setup, value: '44', range: '', position: 0 },
    { imprint_method: pad_print, upcharge: run, value: '0.28', range: '(1..49)', position: 1 },
    { imprint_method: pad_print, upcharge: run, value: '0.03', range: '(50..149)', position: 2 },
    { imprint_method: pad_print, upcharge: run, value: '0.02', range: '(150..499)', position: 2 },
    { imprint_method: pad_print, upcharge: run, value: '0.02', range: '500+', position: 4 },
    { imprint_method: color_print, upcharge: setup, value: '44', range: '', position: 0 },
    { imprint_method: color_print, upcharge: run, value: '0.28', range: '(1..49)', position: 1 },
    { imprint_method: color_print, upcharge: run, value: '0.03', range: '(50..149)', position: 2 },
    { imprint_method: color_print, upcharge: run, value: '0.02', range: '(150..499)', position: 2 },
    { imprint_method: color_print, upcharge: run, value: '0.02', range: '500+', position: 4 },
    { imprint_method: photo_grafixx, upcharge: setup, value: '76', range: '', position: 0 },
    { imprint_method: photo_grafixx, upcharge: run, value: '2.39', range: '(1..49)', position: 1 },
    { imprint_method: photo_grafixx, upcharge: run, value: '1.43', range: '(50..149)', position: 2 },
    { imprint_method: photo_grafixx, upcharge: run, value: '1.11', range: '(150..499)', position: 2 },
    { imprint_method: photo_grafixx, upcharge: run, value: '0.87', range: '500+', position: 4 }
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
updated_main_color = 0
updated_imprint = 0
num_invalid_before = Spree::Product.where(supplier: supplier, state: :invalid).count
num_invalid_after = 0

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

  # Product colors
  unless hashed[:colorlist].blank?
    colors_p1 = hashed[:colorlist].split('or')
    colors = []
    colors_p1.each do |p1|
      p1.split(',').each do |p2|
        colors << p2
      end
    end
    colors.each do |color|
      Spree::ColorProduct.where(product: product, color: hashed[:color] ).first_or_create
    end
    updated_main_color += 1
  end

  screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  Spree::ImprintMethodsProduct.where(
    imprint_method: screen_print_imprint,
    product: product
  ).first_or_create
  updated_imprint += 1

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
