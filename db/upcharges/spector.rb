require 'csv'

# Product Level
file_name = File.join(Rails.root, 'db/upcharge_data/spector_product.csv')

setup_type = Spree::UpchargeType.where(name: 'setup').first.id
run_type = Spree::UpchargeType.where(name: 'run').first.id

upcharge_product_count = 0
upcharge_product_error = 0

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
  imprint_method_id = Spree::ImprintMethod.where(name: imprint_method).first.id

  upcharge_type = upcharge_map[hashed[:charge_name].to_sym][:upcharge_type]
  is_setup = (upcharge_type == 'setup')
  upcharge_type_id = Spree::UpchargeType.where(name:upcharge_type).first.id

  product = Spree::Product.search(master_sku_eq: hashed[:sku]).result.first

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
puts "Loaded #{upcharge_product_count} upcharges, #{upcharge_product_error} failed"

# Supplier level
supplier = Spree::Supplier.where(name: 'Spector').first_or_create

puts 'Loading Spector supplier upcharges'

file_name = File.join(Rails.root, 'db/upcharge_data/spector_supplier.csv')

supplier_upcharge_count = 0

File.open(file_name, 'r').each_line do |line|
  charge_values = line.strip.split(',')
  upcharge_type_id = Spree::UpchargeType.find_by_name(charge_values[0]).id
  Spree::UpchargeSupplier.create(
    upcharge_type_id: upcharge_type_id,
    related_id: supplier.id,
    value: charge_values[1])
  supplier_upcharge_count += 1
end
puts "Loaded #{supplier_upcharge_count} supplier upcharges"
