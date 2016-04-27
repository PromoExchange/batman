require 'csv'
require 'open-uri'

puts 'Loading Xactly 2 preconfigures'

store_name = 'Xactly Company Store'

supplier = Spree::Supplier.where(name: store_name).first

fail 'Unable to find supplier' if supplier.nil?

file_name = File.join(Rails.root, 'db/company_store_data/xactly_preconfigure2.csv')

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

  buyer = Spree::User.where(email: 'mkuh@xactlycorp.com').first
  fail 'Unable to locate XActly user' if buyer.nil?

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

  main_color = Spree::ColorProduct.where(
    product: product,
    color: hashed[:color]).first_or_create

  logo = buyer.logos.where(custom: true).first

  attrs = {
    product: product,
    buyer: buyer,
    imprint_method: imprint_method,
    main_color: main_color,
    logo: logo,
    custom_pms_colors: '166 C'
  }

  Spree::Preconfigure.where(attrs).first_or_create
end
