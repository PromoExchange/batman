require 'csv'
require 'open-uri'

puts 'Loading Anchor Free custom'

store_name = 'AnchorFree Company Store'

supplier = Spree::Supplier.where(name: store_name).first

fail 'Unable to find supplier' if supplier.nil?

# PMS by Imprint
imprints = [
  'Embroidery',
  'Screen Print',
  'Four Color Process',
  'Deboss',
  'Colorprint'
]

black_pms_color = Spree::PmsColor.where(
  name: 'Black',
  pantone: '426',
  hex: '#25282B'
).first_or_create

white_pms_color = Spree::PmsColor.where(
  name: 'White',
  pantone: '000',
  hex: '#FFFFFF'
).first_or_create

imprints.each do |imprint|
  imprint_method = Spree::ImprintMethod.where(name: imprint).first_or_create
  Spree::PmsColorsSupplier.where(
    pms_color: black_pms_color,
    display_name: '426',
    supplier: supplier,
    imprint_method: imprint_method
  ).first_or_create
end

# Products
Spree::Product.where(supplier: supplier).destroy_all

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')

default_attrs = {
  shipping_category: shipping_category,
  tax_category: tax_category,
  available_on: Time.zone.now + 100.years
}

file_name = File.join(Rails.root, 'db/company_store_data/anchorfree.csv')

load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now

CSV.foreach(file_name, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  count += 1
  begin
    desc = hashed[:product_description]

    product_attrs = {
      sku: hashed[:sku],
      name: hashed[:item_name],
      description: hashed[:product_description],
      price: 1.0,
      supplier_id: supplier.id,
      custom_product: true
    }

    product = Spree::Product.create!(default_attrs.merge(product_attrs))

    product.loading!

    # Image
    if Rails.configuration.x.load_images
      begin
        image_path = File.join(Rails.root, "db/product_images/anchorfree/#{product_attrs[:sku]}.jpg")
        product.images << Spree::Image.create!(
          attachment: open(image_path),
          viewable: product
        )
      rescue => e
        ap "Warning: Unable to load product image [#{product_attrs[:sku]}], #{e}"
        image_fail += 1
      end
    end

    # Main Product Color
    Spree::ColorProduct.where(product: product, color: hashed[:color]).first_or_create

    # Prices
    price_code = hashed[:pricecode]
    unless price_code.nil?
      price_code_array = Spree::Price.price_code_to_array(price_code)
      num_prices = price_code_array.size
      num_prices.times do |i|
        quantity_code = "qty" + (i+1).to_s
        next_quantity_code = "qty" + (i+2).to_s
        price_code = "price" + (i+1).to_s
        quantity = hashed[quantity_code.to_sym]
        next_quantity = hashed[next_quantity_code.to_sym]
        price = hashed[price_code.to_sym]

        if i == price_code_array.size - 1
          range = "#{quantity}+"
        else
          range = "(#{quantity}..#{next_quantity.to_i-1})"
        end
        name = range

        Spree::VolumePrice.where(
          variant: product.master,
          name: name,
          range: range,
          amount: price,
          position: i+1,
          discount_type: 'price'
        ).first_or_create
      end
    end

    # Imprint method
    imprint = hashed[:imprint_method]
    case imprint
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

    unless imprint_method.nil?
      Spree::ImprintMethodsProduct.where(
        imprint_method: imprint_method,
        product: product
      ).first_or_create
    end

    # Carton
    product.carton.weight = hashed[:shipping_weight]
    product.carton.quantity = hashed[:shipping_quantity]
    product.carton.originating_zip = hashed[:fob]
    if hashed[:shipping_dimensions].present?
      dimensions = hashed[:shipping_dimensions].gsub(/[A-Z]/, '').delete(' ').split('x')
      product.carton.length = dimensions[0]
      product.carton.width = dimensions[1]
      product.carton.height = dimensions[2]
      product.carton.save!
    end
    fail "Invalid carton #{hashed[:sku]}" unless product.carton.active?

    product.check_validity!
    product.loaded! if product.state == 'loading'
  rescue => e
    load_fail += 1
    ap "Error in #{hashed[:sku]} product data: #{e}"
  ensure
    ActiveRecord::Base.clear_active_connections!
  end
end
