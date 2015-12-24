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
  laser_engrave_imprint = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
  geo_panel_imprint = Spree::ImprintMethod.where(name: 'Geo-Panel').first_or_create
  digital_laminate_imprint = Spree::ImprintMethod.where(name: 'Digital Laminate Panel').first_or_create
  pad_print_imprint = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
  deboss_imprint = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  true_color_direct_imprint = Spree::ImprintMethod.where(name: 'True Color Direct Digital').first_or_create

  logomatic_imprint = Spree::ImprintMethod.where(name: 'Logomatic').first_or_create
  embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  gemphoto_imprint = Spree::ImprintMethod.where(name: 'Gemphoto').first_or_create

  add_charge(product, screen_print_imprint, setup_upcharge, '55', '', 'G', 0)

  add_charge(product, laser_engrave_imprint, setup_upcharge, '55', '', 'G', 0)

  add_charge(product, geo_panel_imprint, setup_upcharge, '55', '', 'G', 0)

  add_charge(product, digital_laminate_imprint, setup_upcharge, '55', '', 'G', 0)

  add_charge(product, pad_print_imprint, setup_upcharge, '55', '', 'G', 0)

  add_charge(product, deboss_imprint, setup_upcharge, '70', '', 'G', 0)

  add_charge(product, true_color_direct_imprint, setup_upcharge, '55', '', 'G', 0)
end

puts 'Loading Starline products'

supplier = Spree::Supplier.where(dc_acct_num: '100512')

file_name = File.join(Rails.root, 'db/product_data/starline.csv')
db_load_fail = 0
db_product_count = Spree::Product.where(supplier: supplier).count
in_file_count = 0
found_ids = []
invalid_carton_count = 0
updated_carton_count = 0
updated_upcharge_count = 0
updated_main_color = 0
updated_imprint_method = 0

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

  product.carton.weight = hashed[:boxlbs]
  product.carton.quantity = hashed[:piecesperbox]
  product.carton.originating_zip = '01843-1066'
  product.carton.length = hashed[:boxlength]
  product.carton.width = hashed[:boxwidth]
  product.carton.height = hashed[:boxheight]

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
  unless hashed[:productcolors].blank?
    colors = hashed[:productcolors].split(',')
    if colors.count > 0
      Spree::ColorProduct.where(product: product).destroy_all
      colors.each do |color|
        Spree::ColorProduct.create( product: product , color: color.strip)
      end
      updated_main_color += 1
    end
  end

  # Imprint methods
  unless hashed[:imprintmethods].blank?
    imprint_methods = hashed[:imprintmethods].split(',')
    if imprint_methods.count > 0
      Spree::ImprintMethodsProduct.where(product: product).destroy_all
      imprint_methods.each do |imprint_method|
        imprint_method = 'Screen Print' if imprint_method.strip == 'Silkscreen'
        imprint = Spree::ImprintMethod.where(name: imprint_method).first_or_create

        imprint = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
        Spree::ImprintMethodsProduct.where(
          imprint_method: imprint,
          product: product
        ).first_or_create

      end
      updated_imprint_method += 1
    end
  end
end

# Add upcharges to those remaining
in_db_only = Spree::Product.where(supplier: supplier).where.not(id: found_ids).count

Spree::Product.where(supplier: supplier).where.not(id: found_ids).each do |prod|
  add_upcharges(prod)
  updated_upcharge_count += 1
  putc '.' if updated_upcharge_count % 10 == 0
end

Spree::Product.where(supplier: supplier).each do |product|
  product.loading!
  product.check_validity!
  product.loaded! if product.state == 'loading'
end

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
