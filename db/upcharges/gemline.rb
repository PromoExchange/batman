require 'csv'
require 'imprint_upcharge_loader'

# Imprint Level
ImprintUpchargeLoader::load('gemline_imprint.csv')

# Supplier level
puts 'Loading Gemline supplier upcharges'

supplier = Spree::Supplier.where(name: 'Gemline').first_or_create

file_name = File.join(Rails.root, 'db/upcharge_data/gemline_supplier.csv')
supplier_upcharge_count = 0
# Supplier Level
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
