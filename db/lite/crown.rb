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

def add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
  volume_price = Spree::VolumePrice.where(variant_id: product.master).order(:position)
  quantity_count = 1
  volume_price.each do |v|
    value = hashed["run_chargeqty#{quantity_count}".to_sym]
    range = v.range
    position = quantity_count
    add_charge(
      product,
      imprint_method,
      upcharge_type,
      value,
      range,
      hashed[:code],
      position
    )
    quantity_count += 1
  end
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

puts 'Loading Crown products'

supplier = Spree::Supplier.where(dc_acct_num: '101684')

file_name = File.join(Rails.root, 'db/product_data/crown.csv')
db_load_fail = 0
db_product_count = Spree::Product.where(supplier: supplier).count
in_file_count = 0
found_ids = []
invalid_carton_count = 0
updated_carton_count = 0
updated_upcharge_count = 0
updated_main_color = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  sku = hashed[:item_sku]

  in_file_count += 1
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{sku}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{sku}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:shipping_weight_lbs]
  product.carton.quantity = hashed[:shipping_quantity]
  product.carton.originating_zip = '36606-2506'
  unless hashed[:shipping_dimensions_inch].blank?
    dimensions = hashed[:shipping_dimensions_inch].gsub(/[A-Z]/, '').delete(' ').split('x')
    product.carton.length = dimensions[0]
    product.carton.width = dimensions[1]
    product.carton.height = dimensions[2]
  end

  if product.carton.active?
    product.carton.save!
    updated_carton_count += 1
  else
    invalid_carton_count += 1
  end

  # Product Colors
  # available_colors
  unless hashed[:available_colors].blank?
    colors = hashed[:available_colors].split(',')
    if colors.count > 0
      Spree::ColorProduct.where(product: product).destroy_all
      colors.each do |color|
        Spree::ColorProduct.create( product: product , color: color.strip)
      end
      updated_main_color += 1
    end
  end

  # add_upcharges(product)
  # updated_upcharge_count += 1
end

in_db_only = Spree::Product.where(supplier: supplier).where.not(id: found_ids).count

upcharge_db_load_fail = 0
upcharge_found_ids = []
upcharge_in_file_count = 0
updated_upcharge_count = 0

file_name = File.join(Rails.root, 'db/upcharge_data/crown_product.csv')
CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash
  
  if upcharge_in_file_count % 10
    puts "."
  end

  sku = hashed[:item_sku]

  upcharge_in_file_count += 1

  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{sku}'").first

  if product.nil?
    upcharge_db_load_fail += 1
    # puts "ERROR: Failed to find product [#{sku}]"
    next
  end

  upcharge_found_ids << product.id

  setup_upcharge = Spree::UpchargeType.where(name: 'setup').first
  run_upcharge = Spree::UpchargeType.where(name: 'additional_color_run').first

  Spree::UpchargeProduct.where(product: product).destroy_all

  screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  pen_imprint = Spree::ImprintMethod.where(name: 'Pen').first_or_create
  deboss_imprint = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  laser_engraving_imprint = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
  color_label_imprint = Spree::ImprintMethod.where(name: 'Color Label').first_or_create
  four_color_imprint = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
  # logomatic_imprint = Spree::ImprintMethod.where(name: 'Logomatic').first_or_create
  # embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  # gemphoto_imprint = Spree::ImprintMethod.where(name: 'Gemphoto').first_or_create

  value = 0

  charge_name = hashed[:charge_name].strip
  if charge_name == 'Set-Up Charge/Change of Copy'
    add_charge(
      product,
      screen_print_imprint,
      setup_upcharge,
      hashed[:setup],
      '1+',
      hashed[:code],
      0
    )
    updated_upcharge_count += 1
  elsif charge_name == 'Per Color Run Charge'
    imprint_method = screen_print_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == 'Debossing Set-Up/Change of Copy'
    add_charge(
      product,
      deboss_imprint,
      setup_upcharge,
      hashed[:setup],
      '1+',
      hashed[:code],
      0
    )
    updated_upcharge_count += 1
  elsif charge_name == 'Pen Imprint Set-Up Charge'
    add_charge(
      product,
      pen_imprint,
      setup_upcharge,
      hashed[:setup],
      '1+',
      hashed[:code],
      0
    )
    updated_upcharge_count += 1
  elsif charge_name == 'Pen Imprint Run Charge'
    imprint_method = pen_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == '2nd Location Imprint'
    next
  elsif charge_name == 'Sharpening'
    next
  elsif charge_name == '2nd Side Imprint'
    next
  elsif charge_name == '2nd Pole Imprint Run Charge'
    next
  elsif charge_name == '2nd Location Imprint'
    next
  elsif charge_name == 'Multi Color Label Imprint Run Charge'
    imprint_method = color_label_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == 'Optional Carabiner Charge'
    next
  elsif charge_name == 'Multi Color Run Charge  Per Color'
    imprint_method = screen_print_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == '2nd Location & Multi Color Imprint Charge'
    imprint_method = screen_print_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == 'Optional Pen Imprint Run Charge Per Piece'
    next
  elsif charge_name == 'Color Surge PMS Color Match Per Color'
    next
  elsif charge_name == 'Color Surge 4 Color Process Run Charge'
    imprint_method = four_color_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == 'Set-Up/Change of Copy/Reorder'
    add_charge(
      product,
      screen_print_imprint,
      setup_upcharge,
      hashed[:setup],
      '1+',
      hashed[:code],
      0
    )
    updated_upcharge_count += 1
  elsif charge_name == 'Sleeve Imprint Run Charge'
    next
  elsif charge_name == 'Silk Screen Set-Up/Change of Copy'
    add_charge(
      product,
      screen_print_imprint,
      setup_upcharge,
      hashed[:setup],
      '1+',
      hashed[:code],
      0
    )
    updated_upcharge_count += 1
  elsif charge_name == 'Laser Engraving Set-Up/Change of Copy'
    add_charge(
      product,
      laser_engraving_imprint,
      setup_upcharge,
      hashed[:setup],
      '1+',
      hashed[:code],
      0
    )
    updated_upcharge_count += 1
  elsif charge_name == 'Assembly Charge'
    next
  elsif charge_name == 'Per Additional Color Imprint'
    imprint_method = screen_print_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == 'Color Surge Digital Color Run Charge'
    imprint_method = four_color_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == 'Optional Pen Imprint Run Charge Per Piece'
    next
  elsif charge_name == '2nd Location Engraving'
    next
  elsif charge_name == 'File Preload'
    next
  elsif charge_name == 'Multi Color Imprint Run Charge'
    imprint_method = four_color_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == 'Color Surge'
    add_charge(
      product,
      four_color_imprint,
      setup_upcharge,
      hashed[:setup],
      '1+',
      hashed[:code],
      0
    )
    updated_upcharge_count += 1
  elsif charge_name == 'Color Surge Run Charge'
    imprint_method = four_color_imprint
    upcharge_type = run_upcharge
    add_qty_upcharges(product, imprint_method, upcharge_type, hashed)
    updated_upcharge_count += 1
  elsif charge_name == '2nd Location Imprint Run Charge'
    next
  elsif charge_name == 'Optional Pen Imprint Set-Up/Change of Copy'
    next
  else
    puts "**** #{charge_name}"
  end
end


# Add upcharges to those remaining
# Spree::Product.where(supplier: supplier).where.not(id: found_ids).each do |prod|
#   add_upcharges(prod)
#   updated_upcharge_count += 1
# end

puts "Products in XML: #{in_file_count}"
puts "Products in DB: #{db_product_count}"
puts "Products in XML AND DB: #{found_ids.count}"
puts "Products in XML only: #{db_load_fail}"
puts "Products in DB only: #{in_db_only}"
puts "Products with invalid cartons: #{invalid_carton_count}"
puts "Products updated with carton: #{updated_carton_count}"
puts "Upcharge Products in DB: #{upcharge_found_ids.count}"
puts "Upcharges found in file: #{upcharge_in_file_count}"
puts "Upcharges added: #{updated_upcharge_count}"
puts "Products updated with main product color: #{updated_main_color}"
