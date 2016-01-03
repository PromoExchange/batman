require 'csv'
require 'open-uri'
require './lib/product_loader'

def add_upcharges(product, level)
  Spree::UpchargeProduct.where(product: product).destroy_all

  # upcharges
  setup_upcharge = Spree::UpchargeType.where(name: 'setup').first
  run_upcharge = Spree::UpchargeType.where(name: 'additional_color_run').first

  screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  laser_engrave_imprint = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
  color_blast_imprint = Spree::ImprintMethod.where(name: 'Color Blast').first_or_create
  label_imprint = Spree::ImprintMethod.where(name: 'Label').first_or_create
  four_color_process_imprint = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
  deboss_imprint = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  transfer_imprint = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
  photografixx_imprint = Spree::ImprintMethod.where(name: 'Photo Grafixx').first_or_create
  sublimination_imprint = Spree::ImprintMethod.where(name: 'Sublimation').first_or_create

  ProductLoader::add_charge(product, screen_print_imprint, setup_upcharge, '55', '', 'G', 0)
  ProductLoader::add_charge(product, laser_engrave_imprint, setup_upcharge, '55', '', 'G', 0)
  ProductLoader::add_charge(product, color_blast_imprint, setup_upcharge, '55', '', 'G', 0)
  ProductLoader::add_charge(product, label_imprint, setup_upcharge, '45', '', 'G', 0)
  ProductLoader::add_charge(product, four_color_process_imprint, setup_upcharge, '3100', '', 'G', 0)
  ProductLoader::add_charge(product, deboss_imprint, setup_upcharge, '75', '', 'G', 0)
  ProductLoader::add_charge(product, transfer_imprint, setup_upcharge, '55', '', 'G', 0)
  ProductLoader::add_charge(product, photografixx_imprint, setup_upcharge, '55', '', 'G', 0)
  ProductLoader::add_charge(product, sublimination_imprint, setup_upcharge, '55', '', 'G', 0)

  ProductLoader::add_charge(product, color_blast_imprint, run_upcharge, '0.30', '(1..5000)', 'G', 1)
  ProductLoader::add_charge(product, color_blast_imprint, run_upcharge, '0.25', '(5001..10000)', 'G', 2)
  ProductLoader::add_charge(product, color_blast_imprint, run_upcharge, '0.20', '(10001..20000)', 'G', 3)
  ProductLoader::add_charge(product, color_blast_imprint, run_upcharge, '0.15', '(20001..50000)', 'G', 4)
  ProductLoader::add_charge(product, color_blast_imprint, run_upcharge, '0.15', '50001+', 'G', 5)

  ProductLoader::add_charge(product, laser_engrave_imprint, run_upcharge, '0.45', '(1..5000)', 'G', 1)
  ProductLoader::add_charge(product, laser_engrave_imprint, run_upcharge, '0.40', '(5001..10000)', 'G', 2)
  ProductLoader::add_charge(product, laser_engrave_imprint, run_upcharge, '0.35', '(10001..20000)', 'G', 3)
  ProductLoader::add_charge(product, laser_engrave_imprint, run_upcharge, '0.30', '(20001..50000)', 'G', 4)
  ProductLoader::add_charge(product, laser_engrave_imprint, run_upcharge, '0.25', '50001+', 'G', 5)

  ProductLoader::add_charge(product, four_color_process_imprint, run_upcharge, '0.075', '(5001..10000)', 'G', 1)
  ProductLoader::add_charge(product, four_color_process_imprint, run_upcharge, '0.06', '(10001..20000)', 'G', 2)
  ProductLoader::add_charge(product, four_color_process_imprint, run_upcharge, '0.05', '(20001..50000)', 'G', 3)
  ProductLoader::add_charge(product, four_color_process_imprint, run_upcharge, '0.025', '50001+', 'G', 4)

  other_imprints = []
  other_imprints << screen_print_imprint
  other_imprints << label_imprint
  other_imprints << deboss_imprint
  other_imprints << photografixx_imprint
  other_imprints << sublimination_imprint

  level ||= 'Level 3'
  case level.strip
  when 'Level 1'
    other_imprints.each do |imprint|
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.30', '(1..5000)', 'G', 1)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.25', '(5001..10000)', 'G', 2)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.20', '(10001..20000)', 'G', 3)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.15', '(20001..50000)', 'G', 4)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.15', '50001+', 'G', 5)
    end
  when 'Level 2'
    other_imprints.each do |imprint|
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.35', '(1..5000)', 'G', 1)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.30', '(5001..10000)', 'G', 2)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.25', '(10001..20000)', 'G', 3)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.20', '(20001..50000)', 'G', 4)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.20', '50001+', 'G', 5)
    end
  when 'Level 3'
    other_imprints.each do |imprint|
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.45', '(1..5000)', 'G', 1)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.40', '(5001..10000)', 'G', 2)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.35', '(10001..20000)', 'G', 3)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.30', '(20001..50000)', 'G', 4)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.25', '50001+', 'G', 5)
    end
  when 'Level 4'
    other_imprints.each do |imprint|
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.50', '1+', 'G', 0)
    end
  when 'Level 5'
    other_imprints << transfer_imprint
    other_imprints.each do |imprint|
      ProductLoader::add_charge(product, imprint, run_upcharge, '1.00', '(1..5000)', 'G', 1)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.90', '(5001..10000)', 'G', 2)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.80', '(10001..20000)', 'G', 3)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.75', '(20001..50000)', 'G', 4)
      ProductLoader::add_charge(product, imprint, run_upcharge, '0.70', '50001+', 'G', 5)
    end
  else
    fail "Unknown level: [#{level}]"
  end
end

puts 'Loading Bullet products'

supplier = Spree::Supplier.where(dc_acct_num: '100383')

file_name = File.join(Rails.root, 'db/product_data/bullet.csv')
db_load_fail = 0
db_product_count = Spree::Product.where(supplier: supplier).count
in_file_count = 0
found_ids = []
invalid_carton_count = 0
updated_carton_count = 0
updated_upcharge_count = 0
updated_main_color = 0
updated_imprint_method = 0
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


  unless hashed[:catalogweight].blank?
    catalog_weight = hashed[:catalogweight]
    bits = catalog_weight.split('per')
    if bits.count == 2
      product.carton.weight = bits[0].gsub(/[^0-9]/,'')
      product.carton.quantity = bits[1].gsub(/[^0-9]/,'')
    end
    product.carton.originating_zip = '33013'

    product.carton.length = 12
    product.carton.width = 13
    product.carton.height = 14

    if product.carton.active?
      product.carton.save!
      updated_carton_count += 1
    else
      invalid_carton_count += 1
    end
  end

  # Product Colors
  # available_colors
  unless hashed[:colorlist].blank?
    colors = hashed[:colorlist].split(',')
    if colors.count > 0
      Spree::ColorProduct.where(product: product).destroy_all
      colors.each do |color|
        Spree::ColorProduct.create( product: product , color: color.strip)
      end
      updated_main_color += 1
    end
  end

  # Imprint Methods
  unless hashed[:imprinttextall].blank?
    downcased_imprint = hashed[:imprinttextall].downcase

    imprints = []

    if /colorprint/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    end

    if /laser engraved/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
    end

    if /offset/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
    end

    if /direct process/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
    end

    if /labeling/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Label').first_or_create
    end

    if /colorlabel/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Label').first_or_create
    end

    if /colorblast/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Color Blast').first_or_create
    end

    if /debossed/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Deboss').first_or_create
    end

    if /heat transferred/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Transfer').first_or_create
    end

    if /sublimation/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Sublimation').first_or_create
    end

    if /photografixx/.match(downcased_imprint)
      imprints << Spree::ImprintMethod.where(name: 'Photo Grafixx').first_or_create
    end

    if imprints.count == 0
      imprints << Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    end

    imprints.each do |imprint|
      Spree::ImprintMethodsProduct.where(
        imprint_method: imprint,
        product: product
      ).first_or_create
    end
    updated_imprint_method += 1
  end

  add_upcharges(product, hashed[:catalogruncharges])
  updated_upcharge_count += 1

  product.loading!
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
puts "Products updated with upcharges: #{updated_upcharge_count}"
puts "Products updated with main product color: #{updated_main_color}"
puts "Products updated with imprint method: #{updated_imprint_method}"
puts "Product invalid before: #{num_invalid_before}"
puts "Product invalid after: #{num_invalid_after}"
