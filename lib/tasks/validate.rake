def prod_desc(p)
  "#{p.id}:#{p.sku}:#{p.name}"
end

namespace :product do
  task shipping_estimate: :environment do
    # SM-2404
    shipping_dimensions = [12, 12, 12]
    shipping_weight = 20 * 16
    originating_zip = '33013'
    destination_zip = '98109'

    package = ActiveShipping::Package.new(
      shipping_weight,
      shipping_dimensions,
      units: :imperial
    )

    origin = ActiveShipping::Location.new(
      country: 'USA',
      zip: originating_zip
    )

    destination = ActiveShipping::Location.new(
      country: 'USA',
      zip: destination_zip
    )

    ups = ActiveShipping::UPS.new(
      login: ENV['UPS_API_USERID'],
      password: ENV['UPS_API_PASSWORD'],
      key: ENV['UPS_API_KEY']
    )

    response = ups.find_rates(origin, destination, package)

    ups_rates = response.rates.sort_by(&:price).collect { |rate| [rate.service_name, rate.price, rate.delivery_date] }

    ups_rates.each do |rate|
      puts "Shipping name #{rate[0]} Rate #{rate[1]} Delivery Date #{rate[2]}"
    end
  end

  task auction_report: :environment do
    puts "Users: #{Spree::User.count}"
    puts "Products: #{Spree::Product.count}"
    puts 'Auctions:'
    puts "  Open: #{Spree::Auction.open.count}"
    puts "  Waiting: #{Spree::Auction.waiting.count}"
    puts "  Closed: #{Spree::Auction.closed.count}"
    puts "  Ended: #{Spree::Auction.ended.count}"
    puts "  Cancelled: #{Spree::Auction.cancelled.count}"
    puts "  Total: #{Spree::Auction.count}"
    puts 'Bids:'
    puts "  Open: #{Spree::Bid.open.count}"
    puts "  Accepted: #{Spree::Bid.accepted.count}"
    puts "  Cancelled: #{Spree::Bid.cancelled.count}"
    puts "  Completed: #{Spree::Bid.completed.count}"
    puts "Bid Total: #{Spree::Order.sum(:total).to_f}"
  end

  task revalidate: :environment do
    begin
      product_count = Spree::Product.count
      before_count = Spree::Product.where(state: 'invalid').count
      product_processed = 0
      Spree::Product.all.each do |product|
        product.loading!
        product.check_validity!
        product.loaded! if product.state == 'loading'
        product_processed += 1
        percentage = (100 * (product_processed.to_f / product_count.to_f)).round(4)
        puts "Processed:#{product_processed} of #{product_count}, (%#{percentage})" if (product_processed % 10) == 0
      end
      after_count = Spree::Product.where(state: 'invalid').count
      puts "Product invalid before: #{before_count}"
      puts "Product invalid after: #{after_count}"
    rescue => e
      puts("ERROR: #{e.message}")
    end
  end

  task product_report: :environment do
    num_total_products = Spree::Product.count
    num_valid_products_with_prices = 0
    num_invalid_products_with_prices = 0

    num_prebidable_active = 0
    valid_products = Spree::Product.where(state: :active)
    valid_products.each do |product|
      num_prebidable_active += 1 if product.prebid_ability?
      num_valid_products_with_prices += 1 if Spree::Variant.find_by(product: product).volume_prices.count > 0
    end
    num_valid_products = valid_products.count

    num_prebidable_invalid = 0
    invalid_products = Spree::Product.where(state: :invalid)
    invalid_products.each do |product|
      num_prebidable_invalid += 1 if product.prebid_ability?
      num_invalid_products_with_prices += 1 if Spree::Variant.find_by(product: product).volume_prices.count > 0
    end
    num_invalid_products = invalid_products.count

    num_loading_products = Spree::Product.where(state: :loading).count

    puts "Number of products: #{num_total_products}"
    puts "Number of invalid products: #{num_invalid_products}"
    puts "Number of active products: #{num_valid_products}"
    puts "Number of loading products: #{num_loading_products}"
    puts "Number of active products with prices: #{num_valid_products_with_prices}"
    puts "Number of invalid products with prices: #{num_invalid_products_with_prices}"
    puts "Number of loading products: #{num_loading_products}"
    puts "Number of prebidable active products: #{num_prebidable_active}"
    puts "Number of prebidable invalid products: #{num_prebidable_invalid}"
  end
end
