require 'csv'
require 'imprint_upcharge_loader'

# Imprint Level
ImprintUpchargeLoader::load('primeline_imprint.csv')

# Product Level
file_name = File.join(Rails.root, 'db/product_data/primeline.csv')

setup_type = Spree::UpchargeType.where(name: 'setup').first.id
run_type = Spree::UpchargeType.where(name: 'run').first.id

upcharge_product_count = 0
upcharge_product_error = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product = Spree::Product.search(master_sku_eq: hashed[:productitem].strip).result.first

  if product.nil?
    puts "Error: Failed to find product #{hashed[:productitem]}"
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

  attrs = {
    upcharge_type_id: run_type,
    related_type: 'Spree::Product',
    related_id: product.id,
    value: hashed[:runningcharge]
  }

  Spree::Upcharge.create(attrs)
  upcharge_product_count += 1
end
puts "Loaded #{upcharge_product_count} upcharges, #{upcharge_product_error} failed"
