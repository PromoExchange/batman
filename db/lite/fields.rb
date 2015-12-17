require 'csv'
require 'open-uri'

puts 'Loading Fields products'

supplier = Spree::Supplier.where(name: 'Fields').first_or_create

file_name = File.join(Rails.root, 'db/product_data/fields.csv')
load_fail = 0
count = 0
beginning_time = Time.zone.now

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  count += 1

  product = Spree::Product.joins(:master).where("spree_variants.sku='#{hashed[:item_]}'").first

  if product.nil?
    puts "ERROR: Failed to find product [#{hashed[:item_]}]"
    next
  end

  product.carton.weight = hashed[:weight_per_carton_lbs]
  product.carton.quantity = hashed[:quantity_per_box]
  product.carton.originating_zip = '01843-1066'
  dimensions = hashed[:carton_dimensions].gsub(/[A-Z]/, '').delete(' ').split('x')
  product.carton.length = dimensions[0]
  product.carton.width = dimensions[1]
  product.carton.height = dimensions[2]

  product.carton.save!

  # upcharges
  setup_upcharge = Spree::UpchargeType.where(name: 'setup').first
  run_upcharge = Spree::UpchargeType.where(name: 'run').first

  screen_print_imprint = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  deboss_imprint = Spree::ImprintMethod.where(name: 'Deboss').first_or_create
  logomatic_imprint = Spree::ImprintMethod.where(name: 'Logomatic').first_or_create
  embroidery_imprint = Spree::ImprintMethod.where(name: 'Embroidery').first_or_create
  gemphoto_imprint = Spree::ImprintMethod.where(name: 'Gemphoto').first_or_create

  product.upcharges.destroy_all

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: screen_print_imprint,
    value: '55',
    price_code: 'V',
    upcharge_type: setup_upcharge
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: screen_print_imprint,
    value: '0.99',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '(6..99)',
    position: 1
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: screen_print_imprint,
    value: '0.74',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '(100..299)',
    position: 2
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: screen_print_imprint,
    value: '0.59',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '(300..999)',
    position: 3
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: screen_print_imprint,
    value: '0.45',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '1000+',
    position: 4
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: embroidery_imprint,
    value: '2.80',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '(6..99)',
    position: 1
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: embroidery_imprint,
    value: '2.55',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '(100..299)',
    position: 2
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: embroidery_imprint,
    value: '2.29',
    price_code: 'V',
    upcharge_type: run_upcharge,
    range: '300+',
    position: 3
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: deboss_imprint,
    value: '70',
    price_code: 'V',
    upcharge_type: setup_upcharge
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: logomatic_imprint,
    value: '55',
    price_code: 'V',
    upcharge_type: setup_upcharge
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: gemphoto_imprint,
    value: '2.80',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '(6..99)',
    position: 1
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: gemphoto_imprint,
    value: '2.55',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '(100..299)',
    position: 2
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: gemphoto_imprint,
    value: '2.20',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '(300..999)',
    position: 3
  ).first_or_create

  Spree::UpchargeProduct.where(
    product: product,
    imprint_method: gemphoto_imprint,
    value: '2.05',
    upcharge_type: run_upcharge,
    price_code: 'V',
    range: '1000+',
    position: 4
  ).first_or_create
end

puts "Products updated: #{count}"
