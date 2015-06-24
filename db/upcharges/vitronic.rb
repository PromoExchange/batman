require 'csv'

# Product Level
file_name = File.join(Rails.root, 'db/upcharge_data/vitronic_product.csv')

setup_type = Spree::UpchargeType.where(name: 'setup').first.id
run_type = Spree::UpchargeType.where(name: 'run').first.id

upcharge_product_count = 0
upcharge_product_error = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product = Spree::Product.search(master_sku_eq: hashed[:sku]).result.first

  if product.nil?
    puts "Error: Failed to find product #{hashed[:sku]}"
    upcharge_product_error += 1
    next
  end

  is_setup = (hashed[:charge_type] == 'SETUP')

  attrs = {
    upcharge_type_id: (is_setup ? setup_type : run_type),
    related_type: 'Spree::Product',
    related_id: product.id,
    actual: hashed[:charge_name],
    price_code: hashed[:code]
  }

  if is_setup
    # Setup records do not have ranges and use only the setup field for value
    attrs[:value] = hashed[:setup]
    attrs[:range] = nil
    Spree::Upcharge.create(attrs)
  else
    volume_price = Spree::VolumePrice.where(variant_id: product.master).order(:position)
    quantity_count = 1
    volume_price.each do |v|
      attrs[:value] = hashed["run_chargeqty#{quantity_count}".to_sym]
      attrs[:range] = v.range
      Spree::Upcharge.create(attrs)
      quantity_count += 1
    end
  end
  upcharge_product_count += 1
end

puts "Loaded #{upcharge_product_count} upcharges, #{upcharge_product_error} failed"

# Supplier level
supplier = Spree::Supplier.find_by_name('Vitronic')

puts 'Loading Vitronic supplier upcharges'

file_name = File.join(Rails.root, 'db/upcharge_data/vitronic_supplier.csv')

supplier_upcharge_count = 0

File.open(file_name, 'r').each_line do |line|
  charge_values = line.strip.split(',')
  upcharge_type_id = Spree::UpchargeType.find_by_name(charge_values[0]).id
  Spree::Upcharge.create(
    upcharge_type_id: upcharge_type_id,
    related_type: 'Spree::Supplier',
    related_id: supplier.id,
    value: charge_values[1])
  supplier_upcharge_count += 1
end

puts "Loaded #{supplier_upcharge_count} supplier upcharges"
