require 'csv'
require 'open-uri'

puts 'Loading PIMCO custom'

store_name = 'PIMCO Company Store'

supplier = Spree::Supplier.where(name: store_name).first

fail 'Unable to find supplier' if supplier.nil?

# Clean up
Spree::Product.where(supplier: supplier).each do |product|
  auctions = Spree::Auction.where(state: :custom_auction, product: product).each do |auction|
    Spree::Bid.where(auction: auction).destroy_all
    auction.destroy
  end
  product.destroy
end

# Products
Spree::Product.where(supplier: supplier).destroy_all

shipping_category = Spree::ShippingCategory.find_by_name!('Default')
tax_category = Spree::TaxCategory.find_by_name!('Default')


load_fail = 0
image_fail = 0
count = 0
beginning_time = Time.zone.now

CSV.parse(S3_CS_BUCKET.objects['pimco/data/products.csv'].read, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  count += 1
  begin
    default_attrs = {
      shipping_category: shipping_category,
      tax_category: tax_category,
      available_on: Time.zone.now + 100.years
    }

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
        product.images << Spree::Image.create!(
          attachment: open(S3_CS_BUCKET.objects["pimco/data/product_images/#{product_attrs[:sku]}.jpg"].public_url),
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
    if price_code.present?
      price_code_array = Spree::Price.price_code_to_array price_code
      price_code_array.size.times do |i|
        quantity_code = "qty#{i + 1}"
        next_quantity_code = "qty#{i + 2}"
        price_code = "price#{i + 1}"
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
          discount_type: 'price',
          price_code: hashed[:pricecode]
        ).first_or_create
      end
    end

    # Imprint method
    case hashed[:imprint_method]
    when 'screen_print'
      imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
    else
      puts "Unknown Method - #{hashed[:imprint_method]}"
    end

    if imprint_method.present?
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

# UPCHARGES
puts 'Loading PIMCO upcharges'

CSV.parse(S3_CS_BUCKET.objects['pimco/data/upcharges.csv'].read, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash
  product = Spree::Product.joins(:master).where("spree_variants.sku='#{hashed[:sku]}'").first
  product.loading!

  fail "Failed to find product #{hashed[:sku]}" if product.nil?

  case hashed[:imprint_method]
  when 'screen_print'
    imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  else
    puts "Unknown Method - #{hashed[:imprint_method]}"
  end

  Spree::UpchargeProduct.where(
    upcharge_type_id: Spree::UpchargeType.where(name: hashed[:type]).first_or_create.id,
    related_id: product.id,
    actual: hashed[:type].titleize,
    price_code: hashed[:code],
    imprint_method_id: imprint_method.id,
    value: hashed[:value],
    range: hashed[:range]
  ).first_or_create

  product.check_validity!
  product.loaded! if product.state == 'loading'
end

# PRECONFIGURE
puts 'Loading PIMCO preconfigures'

CSV.parse(S3_CS_BUCKET.objects['pimco/data/preconfigure.csv'].read, headers: true, header_converters: :symbol) do |row|
  hashed = row.to_hash

  product = Spree::Product.joins(:master).where("spree_variants.sku='#{hashed[:sku]}'").first
  buyer = Spree::User.where(email: 'amanda.witschger@netmining.com').first
  fail 'Unable to locate Netmining user' if buyer.nil?

  case hashed[:imprint_method]
  when 'screen_print'
    imprint_method = Spree::ImprintMethod.where(name: 'Screen Print').first_or_create
  else
    puts "Unknown Imprint Method - #{imprint}"
  end

  Spree::Preconfigure.where(
    product: product,
    buyer: buyer,
    imprint_method: imprint_method,
    main_color: Spree::ColorProduct.where(product: product, color: hashed[:color]).first_or_create,
    logo: buyer.logos.where(custom: true).first,
    custom_pms_colors: '534 C'
  ).first_or_create
end
