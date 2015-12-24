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

puts 'Loading Vitronic products'

supplier = Spree::Supplier.where(dc_acct_num: '101715')

file_name = File.join(Rails.root, 'db/product_data/vitronic.csv')
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

  in_file_count += 1
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{hashed[:sku]}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{hashed[:sku]}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:shipping_weight_lbs]
  product.carton.quantity = hashed[:shipping_quantity]
  product.carton.originating_zip = '63935'
  if hashed[:shipping_dimensions_inch].present?
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
end

in_db_only = Spree::Product.where(supplier: supplier).where.not(id: found_ids).count

# Product Level
file_name = File.join(Rails.root, 'db/upcharge_data/vitronic_product.csv')

setup_type = Spree::UpchargeType.where(name: 'setup').first.id
run_type = Spree::UpchargeType.where(name: 'additional_color_run').first

upcharge_product_count = 0
upcharge_product_error = 0

Spree::Product.where(supplier: supplier).each do |product|
  product.upcharges.destroy_all
end

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  upcharge_map = {
    'Image Lock Setup Charge': {
      imprint_method: 'Image Lock',
      upcharge_type: 'setup'
    },
    'Embroidery Setup Charge': {
      imprint_method: 'Embroidery',
      upcharge_type: 'setup'
    },
    'Vivid Expressions Additional Location Run Charge': {
      imprint_method: 'Vivid Expression',
      upcharge_type: 'additional_location_run'
    },
    'Image Lock Additional Color Run Charge': {
      imprint_method: 'Image Lock',
      upcharge_type: 'additional_color_run'
    },
    'Screen Print Setup Charge': {
      imprint_method: 'Screen Print',
      upcharge_type: 'setup'
    },
    'Screen Print Second Color Run Charge': {
      imprint_method: 'Screen Print',
      upcharge_type: 'second_color_run'
    },
    'Screen Print Additional Color Run Charge': {
      imprint_method: 'Screen Print',
      upcharge_type: 'additional_color_run'
    },
    'Screen Print Multiple Color Run Charge': {
      imprint_method: 'Screen Print',
      upcharge_type: 'multiple_color_run'
    },
    'Hot Stamp Setup Charge': {
      imprint_method: 'Hot Stamp',
      upcharge_type: 'setup'
    },
    'Hot Stamp Multiple Color Run Charge': {
      imprint_method: 'Hot Stamp',
      upcharge_type: 'second_color_run'
    },
    'Deboss Setup Charge': {
      imprint_method: 'Deboss',
      upcharge_type: 'setup'
    },
    '4-color Process/digital Imprint Setup Charge': {
      imprint_method: 'Four Color Process',
      upcharge_type: 'setup'
    },
    'Four Color Process Setup Charge': {
      imprint_method: 'Four Color Process',
      upcharge_type: 'setup'
    },
    'Photo Magic Setup Charge': {
      imprint_method: 'Photo Magic',
      upcharge_type: 'setup'
    },
    'Over 5,000 Stitches Run Charge': {
      imprint_method: 'Embroidery',
      upcharge_type: 'run'
    },
    'Pad Print Setup Charge': {
      imprint_method: 'Pad Print',
      upcharge_type: 'setup'
    }
  }

  imprint_method = upcharge_map[hashed[:charge_name].to_sym][:imprint_method]
  imprint_method_id = Spree::ImprintMethod.where(name: imprint_method).first_or_create

  upcharge_type = upcharge_map[hashed[:charge_name].to_sym][:upcharge_type]
  is_setup = (upcharge_type == 'setup')
  upcharge_type_id = Spree::UpchargeType.where(name:upcharge_type).first.id

  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{hashed[:sku]}'").first

  if product.nil?
    puts "Error: Failed to find product #{hashed[:sku]}"
    upcharge_product_error += 1
    next
  end

  attrs = {
    upcharge_type_id: upcharge_type_id,
    related_id: product.id,
    actual: hashed[:charge_name],
    price_code: hashed[:code],
    imprint_method_id: imprint_method_id
  }

  if is_setup
    # Setup records do not have ranges and use only the setup field for value
    attrs[:value] = hashed[:setup]
    attrs[:range] = nil
    Spree::UpchargeProduct.create(attrs)
    upcharge_product_count += 1
  else
    volume_price = Spree::VolumePrice.where(variant_id: product.master).order(:position)
    quantity_count = 1
    volume_price.each do |v|
      attrs[:value] = hashed["run_chargeqty#{quantity_count}".to_sym]
      attrs[:range] = v.range
      attrs[:position] = quantity_count
      Spree::UpchargeProduct.create(attrs)
      quantity_count += 1
      upcharge_product_count += 1
    end
  end
end

puts "Products in XML: #{in_file_count}"
puts "Products in DB: #{db_product_count}"
puts "Products in XML AND DB: #{found_ids.count}"
puts "Products in XML only: #{db_load_fail}"
puts "Products in DB only: #{in_db_only}"
puts "Products with invalid cartons: #{invalid_carton_count}"
puts "Products updated with carton: #{updated_carton_count}"
puts "Products updated with upcharges: #{upcharge_product_count}"
puts "Products updated with main product color: #{updated_main_color}"
