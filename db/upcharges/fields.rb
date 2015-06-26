require 'csv'
require 'imprint_upcharge_loader'

# Product Level
file_name = File.join(Rails.root, 'db/product_data/fields.csv')

setup_type = Spree::UpchargeType.where(name: 'setup').first.id
run_type = Spree::UpchargeType.where(name: 'run').first.id

upcharge_product_count = 0
upcharge_product_error = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product = Spree::Product.search(master_sku_eq: hashed[:productcode]).result.first

  if product.nil?
    puts "Error: Failed to find product #{hashed[:productcode]}"
    upcharge_product_error += 1
    next
  end

  added_charge = false

  setup_charge_value = hashed[:setup_charge]
  if setup_charge_value && setup_charge_value != 'No set-up charge.'
    attrs = {
      upcharge_type_id: setup_type,
      related_type: 'Spree::Product',
      related_id: product.id,
      value: hashed[:setup_charge]
    }
    Spree::Upcharge.create(attrs)
    added_charge = true
  end

  if hashed[:run_charge]
    attrs = {
      upcharge_type_id: run_type,
      related_type: 'Spree::Product',
      related_id: product.id,
      value: hashed[:run_charge]
    }
    Spree::Upcharge.create(attrs)
    added_charge = true
  end

  upcharge_product_count += 1 unless added_charge == false
end
puts "Loaded #{upcharge_product_count} upcharges, #{upcharge_product_error} failed"

# Imprint Level
ImprintUpchargeLoader::load('fields_imprint.csv')
