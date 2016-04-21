require 'csv'

# Product Level
file_name = File.join(Rails.root, 'db/company_store_data/xactly_upcharges2.csv')

xactly_2_products = [
  'XA-6240-SXL',
  'XA-6640-SXL',
  'XA-PD46P-25',
  'XA-BA2300',
  'XA-BTR8',
  'XA-CPP5579'
]

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  # HACK: Skip original 2 (this is going to get silly)
  # TODO: I need a cleaner way of adding additional products
  next if xactly_2_products.include?(hashed[:sku])

  product = Spree::Product.joins(:master).where("spree_variants.sku='#{hashed[:sku]}'").first

  product.loading!

  fail "Failed to find product #{hashed[:sku]}" if product.nil?

  upcharge_type = Spree::UpchargeType.where(name: hashed[:type]).first_or_create

  case hashed[:imprint_method]
  when 'embroidery'
    imprint_method = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  when 'screen_print'
    imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  when '4color'
    imprint_method = Spree::ImprintMethod.where(name: 'Four Color Process').first_or_create
  when 'deboss'
    imprint_method = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  when 'colorprint'
    imprint_method = Spree::ImprintMethod.where(name: 'Colorprint').first_or_create
  when 'laser'
    imprint_method = Spree::ImprintMethod.where(name: 'Laser Engraving').first_or_create
  else
    puts "Unknown Method - #{imprint}"
  end

  upcharge_attrs = {
    upcharge_type_id: upcharge_type.id,
    related_id: product.id,
    actual: hashed[:type].titleize,
    price_code: hashed[:code],
    imprint_method_id: imprint_method.id
  }

  upcharge_attrs[:value] = hashed[:value]
  upcharge_attrs[:range] = hashed[:range]

  Spree::UpchargeProduct.where(upcharge_attrs).first_or_create

  product.check_validity!
  product.loaded! if product.state == 'loading'
end
