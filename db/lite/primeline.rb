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

  four_color_process_imprint = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
  deboss_imprint = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  vibratec_imprint = Spree::ImprintMethod.where(name: 'Vibratec').first_or_create
  laser_engrave_imprint = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
  screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  pad_print_imprint = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
  embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create

  add_charge(product, four_color_process_imprint, setup_upcharge, '60', '', 'G', 0)
  add_charge(product, four_color_process_imprint, run_upcharge, '0.65', '1+', 'G', 1)

  add_charge(product, four_color_process_imprint, setup_upcharge, '60', '', 'G', 0)
  add_charge(product, four_color_process_imprint, run_upcharge, '0.65', '1+', 'G', 1)

  add_charge(product, vibratec_imprint, setup_upcharge, '80', '', 'G', 0)
  add_charge(product, four_color_process_imprint, run_upcharge, '0.65', '1+', 'G', 1)

  add_charge(product, deboss_imprint, setup_upcharge, '80', '', 'G', 0)
  add_charge(product, deboss_imprint, run_upcharge, '1.25', '1+', 'G', 1)

  add_charge(product, screen_print_imprint, setup_upcharge, '60', '', 'G', 0)
  add_charge(product, screen_print_imprint, run_upcharge, '1.25', '1+', 'G', 1)

  add_charge(product, laser_engrave_imprint, setup_upcharge, '60', '', 'G', 0)
  add_charge(product, laser_engrave_imprint, run_upcharge, '1.25', '1+', 'G', 1)

  add_charge(product, pad_print_imprint, setup_upcharge, '60', '', 'G', 0)
  add_charge(product, pad_print_imprint, run_upcharge, '1.25', '1+', 'G', 1)

  add_charge(product, embroidery_imprint, setup_upcharge, '35', '', 'G', 0)
  add_charge(product, embroidery_imprint, run_upcharge, '2.25', '1+', 'G', 1)
end

puts 'Loading Primeline products'

supplier = Spree::Supplier.where(dc_acct_num: '100334')

file_name = File.join(Rails.root, 'db/product_data/primeline.csv')
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
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{hashed[:productitem]}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{hashed[:productitem]}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:weightperbox]
  product.carton.quantity = hashed[:piecesperbox]
  product.carton.originating_zip = '01843-1066'
  product.carton.length = hashed[:length]
  product.carton.width = hashed[:width]
  product.carton.height = hashed[:height]

  if product.carton.active?
    product.carton.save!
    updated_carton_count += 1
  else
    invalid_carton_count += 1
  end

  # Product Colors
  unless hashed[:colors].blank?
    colors = hashed[:colors].split(',')
    if colors.count > 0
      Spree::ColorProduct.where(product: product).destroy_all
      colors.each do |color|
        Spree::ColorProduct.create( product: product , color: color.strip)
      end
      updated_main_color += 1
    end
  end

  # Imprint Methods
  unless hashed[:imprint_type].blank?
    method_name = hashed[:imprint_type]
    imprint_method = nil

    if /^Custom/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Molded PVC').first_or_create
    elsif /^Deboss/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
    elsif /^Embroidery/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
    elsif /^Four/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
    elsif /^Full-Color/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
    elsif /^Image Bonding/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
    elsif /^Laser Engraved/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif /^Pad Print/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
    elsif /^Silk Screen/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    elsif /^Transfer/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
    elsif /^VibraTec/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'VibraTec').first_or_create
    elsif /^pad Print/.match(method_name)
      imprint_method = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
    else
      next
    end
    Spree::ImprintMethodsProduct.where(
      imprint_method: imprint_method,
      product: product
    ).first_or_create
    updated_imprint += 1
  end

  add_upcharges(product)
  updated_upcharge_count += 1

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
puts "Products main colors updated: #{updated_main_color}"
puts "Products with invalid cartons: #{invalid_carton_count}"
puts "Products updated with carton: #{updated_carton_count}"
puts "Products updated with upcharges: #{updated_upcharge_count}"
puts "Products updated with imprint method: #{updated_imprint}"
puts "Product invalid before: #{num_invalid_before}"
puts "Product invalid after: #{num_invalid_after}"
