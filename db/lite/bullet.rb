require 'csv'
require 'open-uri'
require './lib/product_loader'

def add_upcharges(product, level = 'Level 3')
  Spree::UpchargeProduct.where(product: product).destroy_all

  # upcharges
  setup = Spree::UpchargeType.where(name: 'setup').first
  run = Spree::UpchargeType.where(name: 'additional_color_run').first

  screen_print = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  laser_engrave = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
  color_blast = Spree::ImprintMethod.where(name: 'Color Blast').first_or_create
  label = Spree::ImprintMethod.where(name: 'Label').first_or_create
  four_color_process = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
  deboss = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  transfer = Spree::ImprintMethod.where(name: 'Transfer').first_or_create
  photografixx = Spree::ImprintMethod.where(name: 'Photo Grafixx').first_or_create
  sublimination = Spree::ImprintMethod.where(name: 'Sublimation').first_or_create

  charges = [
    { imprint_method: screen_print, value: '55' },
    { imprint_method: laser_engrave, value: '55' },
    { imprint_method: color_blast, value: '55' },
    { imprint_method: label, value: '45' },
    { imprint_method: four_color_process, value: '3100' },
    { imprint_method: deboss, value: '75' },
    { imprint_method: transfer, value: '55' },
    { imprint_method: photografixx, value: '55' },
    { imprint_method: sublimination, value: '55' },
    { imprint_method: color_blast, value: '0.30', range: '(1..5000)', position: 1 },
    { imprint_method: color_blast, value: '0.25', range: '(5001..10000)', position: 2 },
    { imprint_method: color_blast, value: '0.20', range: '(10001..20000)', position: 3 },
    { imprint_method: color_blast, value: '0.15', range: '(20001..50000)', position: 4 },
    { imprint_method: color_blast, value: '0.15', range: '50001+', position: 5 },
    { imprint_method: laser_engrave, value: '0.45', range: '(1..5000)', position: 1 },
    { imprint_method: laser_engrave, value: '0.40', range: '(5001..10000)', position: 2 },
    { imprint_method: laser_engrave, value: '0.35', range: '(10001..20000)', position: 3 },
    { imprint_method: laser_engrave, value: '0.30', range: '(20001..50000)', position: 4 },
    { imprint_method: laser_engrave, value: '0.25', range: '50001+', position: 5 },
    { imprint_method: four_color_process, value: '0.075', range: '(5001..10000)', position: 1 },
    { imprint_method: four_color_process, value: '0.06', range: '(10001..20000)', position: 2 },
    { imprint_method: four_color_process, value: '0.05', range: '(20001..50000)', position: 3 },
    { imprint_method: four_color_process, value: '0.025', range: '50001+', position: 4 }
  ]

  case level.strip
  when 'Level 1'
    [screen_print, label, deboss, photografixx, sublimination].each do |imprint|
      charges << { imprint_method: imprint, upcharge: run, value: '0.30', range: '(1..5000)', position: 1 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.25', range: '(5001..10000)', position: 2 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.20', range: '(10001..20000)', position: 3 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.15', range: '(20001..50000)', position: 4 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.15', range: '50001+', position: 5 }
    end
  when 'Level 2'
    [screen_print, label, deboss, photografixx, sublimination].each do |imprint|
      charges << { imprint_method: imprint, upcharge: run, value: '0.35', range: '(1..5000)', position: 1 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.30', range: '(5001..10000)', position: 2 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.25', range: '(10001..20000)', position: 3 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.20', range: '(20001..50000)', position: 4 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.20', range: '50001+', position: 5 }
    end
  when 'Level 3'
    [screen_print, label, deboss, photografixx, sublimination].each do |imprint|
      charges << { imprint_method: imprint, upcharge: run, value: '0.45', range: '(1..5000)', position: 1 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.40', range: '(5001..10000)', position: 2 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.35', range: '(10001..20000)', position: 3 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.30', range: '(20001..50000)', position: 4 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.25', range: '50001+', position: 5 }
    end
  when 'Level 4'
    [screen_print, label, deboss, photografixx, sublimination].each do |imprint|
      charges << { imprint_method: imprint, upcharge: run, value: '0.50', range: '1+' }
    end
  when 'Level 5'
    [screen_print, label, deboss, photografixx, sublimination, transfer].each do |imprint|
      charges << { imprint_method: imprint, upcharge: run, value: '1.00', range: '(1..5000)', position: 1 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.90', range: '(5001..10000)', position: 2 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.80', range: '(10001..20000)', position: 3 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.75', range: '(20001..50000)', position: 4 }
      charges << { imprint_method: imprint, upcharge: run, value: '0.70', range: '50001+', position: 5 }
    end
  else
    fail "Unknown level: [#{level}]"
  end

  charges.each do |charge|
    ProductLoader.add_charge(
      product: product,
      imprint_method: charge[:imprint_method],
      upcharge_type: charge[:upcharge] or setup,
      value: charge[:value],
      range: charge[:range] or '',
      price_code: 'G',
      position: charge[:position] or 0
    )
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
  product = Spree::Product
    .joins(:master)
    .where(supplier: supplier)
    .where("spree_variants.sku='#{hashed[:itemno]}'")
    .first

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
