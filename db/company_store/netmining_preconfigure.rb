require 'csv'
require 'open-uri'

puts 'Loading Netmining preconfigures'

store_name = 'Netmining Company Store'

supplier = Spree::Supplier.where(name: store_name).first

fail 'Unable to find supplier' if supplier.nil?

file_name = File.join(Rails.root, 'db/company_store_data/netmining_preconfigure.csv')

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product = Spree::Product.joins(:master).where("spree_variants.sku='#{hashed[:sku]}'").first
  buyer = Spree::User.where(email: 'amanda.witschger@netmining.com').first
  fail 'Unable to locate Netmining user' if buyer.nil?

  case hashed[:imprint_method]
  when 'embroidery'
    imprint_method = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  when 'screen_print'
    imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  when 'pad_print'
    imprint_method = Spree::ImprintMethod.where(name: 'Pad Print').first_or_create
  when 'deboss'
    imprint_method = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  else
    puts "Unknown Imprint Method - #{imprint}"
  end

  Spree::Preconfigure.where(
    product: product,
    buyer: buyer,
    imprint_method: imprint_method,
    main_color: Spree::ColorProduct.where(product: product, color: hashed[:color]).first_or_create,
    logo: buyer.logos.where(custom: true).first
  ).first_or_create
end
