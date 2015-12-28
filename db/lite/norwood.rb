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

  add_charge(product, screen_print_imprint, setup_upcharge, '30', '', 'G', 0)
  add_charge(product, screen_print_imprint, run_upcharge, '0.12', '1+', 'C', 1)
end

puts 'Loading Norwood products'

supplier = Spree::Supplier.where(dc_acct_num: '132819')

file_name = File.join(Rails.root, 'db/product_data/norwood.csv')
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
  product = Spree::Product.joins(:master).where(supplier: supplier).where("spree_variants.sku='#{hashed[:product_id]}'").first

  if product.nil?
    db_load_fail += 1
    puts "ERROR: Failed to find product [#{hashed[:product_id]}]"
    next
  end

  found_ids << product.id

  product.carton.weight = hashed[:pack_weight]
  product.carton.quantity = hashed[:pack_size]
  product.carton.originating_zip = hashed[:fob_ship_from_zip]
  product.carton.length = '12'
  product.carton.width = '13'
  product.carton.height = '14'

  if product.carton.active?
    product.carton.save!
    updated_carton_count += 1
  else
    invalid_carton_count += 1
  end

  add_upcharges(product)
  updated_upcharge_count += 1

  # Product Color
  unless hashed[:item_type1].blank?
    if hashed[:item_type1] == 'Product Colors'
      hashed[:item_colors1].split('|').each do |color|
        bits = color.split('(')
        Spree::ColorProduct.where(product: product, color: bits[0]).first_or_create
      end
      updated_main_color += 1
    end
  end

  # Imprint Methods
  # TODO: Smelly
  imprint_updated = false
  (1..7).each do |i|
    method_col = 'imprint_method' + i.to_s
    next if hashed[method_col.to_sym].blank?
    imprint_name = hashed[method_col.to_sym]
    if imprint_name == 'Screen Print'
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    elsif imprint_name == 'Offset'
      imprint_method = Spree::ImprintMethod.where(name: 'Offset').first_or_create
    elsif imprint_name == 'Epoxy Dome'
      imprint_method = Spree::ImprintMethod.where(name: 'Epoxy Dome').first_or_create
    elsif imprint_name == 'Deboss'
      imprint_method = Spree::ImprintMethod.where(name: 'Offset').first_or_create
    elsif imprint_name == 'Sublimation'
      imprint_method = Spree::ImprintMethod.where(name: 'Sublimation').first_or_create
    elsif imprint_name == 'Laser Engrave'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint_name == 'Lasered Leather'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint_name == '4-Color Process Heat Transfer'
      imprint_method = Spree::ImprintMethod.where(name: 'Heat Transfer').first_or_create
    elsif imprint_name == 'Pad Print'
      imprint_method = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
    elsif imprint_name == '4-Color Process'
      imprint_method = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
    elsif imprint_name == 'OPP Laminated 4-color process'
      imprint_method = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
    elsif imprint_name == 'Digital'
      imprint_method = Spree::ImprintMethod.where(name: 'Digital').first_or_create
    elsif imprint_name == 'Laser Engrave with Colorfill'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint_name == 'Deep Etch with Colorfill'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint_name == 'Deep Etch'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint_name == 'Digital Heat Transfer'
      imprint_method = Spree::ImprintMethod.where(name: 'Heat Transfer').first_or_create
    elsif imprint_name == 'Laser Etch'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint_name == 'Foil Stamp'
      imprint_method = Spree::ImprintMethod.where(name: 'Foil Stamp').first_or_create
    elsif imprint_name == 'Blind Deboss'
      imprint_method = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
    elsif imprint_name == 'Ink Process'
      imprint_method = Spree::ImprintMethod.where(name: 'Ink Process').first_or_create
    elsif imprint_name == 'Hand Painted'
      imprint_method = Spree::ImprintMethod.where(name: 'Hand Painted').first_or_create
    elsif imprint_name == 'Flexograph'
      imprint_method = Spree::ImprintMethod.where(name: 'Flexograph').first_or_create
    elsif imprint_name == 'Embroidery'
      imprint_method = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
    elsif imprint_name == 'Woven'
      imprint_method = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
    elsif imprint_name == 'Heat Transfer'
      imprint_method = Spree::ImprintMethod.where(name: 'Heat Transfer').first_or_create
    elsif imprint_name == 'britePix&#174; 1-Color'
      imprint_method = Spree::ImprintMethod.where(name: 'britePix').first_or_create
    elsif imprint_name == 'britePix&#174; Full Color'
      imprint_method = Spree::ImprintMethod.where(name: 'britePix').first_or_create
    elsif imprint_name == 'Digital 4-Color Process'
      imprint_method = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
    elsif imprint_name == 'SpectraColor&#174; II'
      imprint_method = Spree::ImprintMethod.where(name: 'SpectraColor').first_or_create
    elsif imprint_name == 'Spin-Cast Medallion'
      imprint_method = nil
    elsif imprint_name == 'Custom-Crafted Medallion'
      imprint_method = nil
    elsif imprint_name == 'Image 3'
      imprint_method = nil
    elsif imprint_name == 'Laser-Engraved Medallion'
      imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    elsif imprint_name == 'Screen-Print Medallion'
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    else
      fail "Unable to find [#{hashed[method_col.to_sym]}]"
    end
    unless imprint_method.nil?
      Spree::ImprintMethodsProduct.where(
        imprint_method: imprint_method,
        product: product
      ).first_or_create
      imprint_updated = true
    end
  end
  updated_imprint += 1 if imprint_updated

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
puts "Products with invalid cartons: #{invalid_carton_count}"
puts "Products updated with carton: #{updated_carton_count}"
puts "Products updated with upcharges: #{updated_upcharge_count}"
puts "Products updated with main color: #{updated_main_color}"
puts "Products updated with imprint method: #{updated_imprint}"
puts "Product invalid before: #{num_invalid_before}"
puts "Product invalid after: #{num_invalid_after}"
