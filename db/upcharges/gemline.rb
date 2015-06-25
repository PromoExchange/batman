require 'csv'

# Imprint Level
puts 'Loading Gemline Imprint level upcharges'

setup_type = Spree::UpchargeType.where(name: 'setup').first.id
run_type = Spree::UpchargeType.where(name: 'run').first.id

file_name = File.join(Rails.root, 'db/upcharge_data/gemline_imprint.csv')
imprint_upcharge_count = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  is_setup = (hashed[:charge_type] == 'SETUP')

  imprint = Spree::ImprintMethod.where(slug: hashed[:imprint_slug]).first

  next if imprint.nil?
  
  attrs = {
    upcharge_type_id: (is_setup ? setup_type : run_type),
    related_type: 'Spree::ImprintMethod',
  }
  attrs[:related_id] = imprint.id

  if is_setup
    attrs[:value] = hashed[:price1]
    Spree::Upcharge.create(attrs)
    imprint_upcharge_count += 1
  else
    (1..5).each do |i|
      range_key = "range#{i}".to_sym
      price_key = "price#{i}".to_sym

      next if hashed[range_key] == '0'

      attrs[:range] = hashed[range_key]
      attrs[:value] = hashed[price_key]
      attrs[:position] = i

      Spree::Upcharge.create(attrs)
      imprint_upcharge_count += 1
    end
  end
end

puts "Loaded #{imprint_upcharge_count} imprint upcharges"

# Supplier level
puts 'Loading Gemline supplier upcharges'

supplier = Spree::Supplier.find_by_name('Gemline')

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
