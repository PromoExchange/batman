require 'csv'

# Imprint Level
puts 'Loading Primeline Imprint level upcharges'

setup_type = Spree::UpchargeType.where(name: 'setup').first.id
run_type = Spree::UpchargeType.where(name: 'run').first.id

file_name = File.join(Rails.root, 'db/upcharge_data/primeline_imprint.csv')
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
