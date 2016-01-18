require 'csv'
require 'open-uri'

puts 'Loading Anchor Free preconfigures'

store_name = 'AnchorFree Company Store'

supplier = Spree::Supplier.where(name: store_name).first

fail 'Unable to find supplier' if supplier.nil?

file_name = File.join(Rails.root, 'db/company_store_data/anchorfree_preconfigure.csv')

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product = Spree::Product.joins(:master).where("spree_variants.sku='#{hashed[:sku]}'").first

  buyer = Spree::User.where(email: 'dwittig@anchorfree.com').first
  fail "Unable to locate AnchorFree user" if buyer.nil?

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
  else
    puts "Unknown Method - #{imprint}"
  end

  main_color = Spree::ColorProduct.where( product:product, color: hashed[:color]).first_or_create

  attrs = {
    product: product,
    buyer: buyer.
    imprint_method: imprint_method,
    main_color: main_color,
    FFFF
    t.integer "logo_id",           null: false
    custom_pms_colors: '321'
  }
end
