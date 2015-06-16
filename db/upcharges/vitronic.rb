require 'csv'

# Supplier level
supplier = Spree::Supplier.find_by_name('Vitronic')

puts "Loading Vitronic supplier upcharges"

file_name = File.join(Rails.root, 'db/upcharge_data/vitronic_supplier.csv')

File.open(file_name,'r').each_line do |line|
  charge_values = line.strip.split(',')
  upcharge_type_id = Spree::UpchargeType.find_by_name(charge_values[0]).id
  Spree::Upcharge.create( upcharge_type_id: upcharge_type_id,
    related_type: 'Spree::Supplier',
    related_id: supplier.id,
    value: charge_values[1])
end

# Product Level
