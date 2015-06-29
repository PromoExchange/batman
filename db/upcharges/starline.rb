require 'csv'
require 'imprint_upcharge_loader'

# Imprint level
ImprintUpchargeLoader::load('starline_imprint.csv')

# Product Level
file_name = File.join(Rails.root, 'db/product_data/starline.csv')

setup_type = Spree::UpchargeType.where(name: 'setup').first.id

upcharge_product_count = 0
upcharge_product_error = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product = Spree::Product.search(master_sku_eq: hashed[:productcode].strip).result.first

  if product.nil?
    puts "Error: Failed to find product #{hashed[:productcode]}"
    upcharge_product_error += 1
    next
  end

  attrs = {
    upcharge_type_id: setup_type,
    related_type: 'Spree::Product',
    related_id: product.id,
    value:  hashed[:setupcharge]
  }
  Spree::Upcharge.create(attrs)
  upcharge_product_count += 1
end
puts "Loaded #{upcharge_product_count} upcharges, #{upcharge_product_error} failed"

# Supplier level
puts 'Loading Starline supplier upcharges'

supplier = Spree::Supplier.where(name: 'Starline').first_or_create

file_name = File.join(Rails.root, 'db/upcharge_data/starline_supplier.csv')

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

# Product Level
