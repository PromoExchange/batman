require 'csv'
require 'imprint_upcharge_loader'

# Product Level
file_name = File.join(Rails.root, 'db/upcharge_data/crown_product.csv')

setup_type = Spree::UpchargeType.where(name: 'setup').first.id
run_type = Spree::UpchargeType.where(name: 'run').first.id

upcharge_product_count = 0
upcharge_product_error = 0

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product = Spree::Product.search(master_sku_eq: hashed[:item_sku]).result.first

  if product.nil?
    puts "Error: Failed to find product #{hashed[:item_sku]}"
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
    upcharge_product_count += 1
  else
    volume_price = Spree::VolumePrice.where(variant_id: product.master).order(:position)
    quantity_count = 1
    volume_price.each do |v|
      attrs[:value] = hashed["run_chargeqty#{quantity_count}".to_sym]
      attrs[:range] = v.range
      attrs[:position] = quantity_count
      Spree::Upcharge.create(attrs)
      quantity_count += 1
      upcharge_product_count += 1
    end
  end
end
puts "Loaded #{upcharge_product_count} upcharges, #{upcharge_product_error} failed"

# Imprint Level
ImprintUpchargeLoader::load('crown_imprint.csv')
