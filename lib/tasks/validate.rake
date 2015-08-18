def prod_desc p
  "#{p.id}:#{p.sku}:#{p.name}"
end

namespace :product do
  task report: :environment do
    puts "Users: #{Spree::User.count}"
    puts "Products: #{Spree::Product.count}"
    puts "Auctions:"
    puts "  Open: #{Spree::Auction.open.count}"
    puts "  Waiting: #{Spree::Auction.waiting.count}"
    puts "  Closed: #{Spree::Auction.closed.count}"
    puts "  Ended: #{Spree::Auction.ended.count}"
    puts "  Cancelled: #{Spree::Auction.cancelled.count}"
    puts "  Total: #{Spree::Auction.count}"
    puts "Bids:"
    puts "  Open: #{Spree::Bid.open.count}"
    puts "  Accepted: #{Spree::Bid.accepted.count}"
    puts "  Cancelled: #{Spree::Bid.cancelled.count}"
    puts "  Completed: #{Spree::Bid.completed.count}"
    puts "Bid Total: #{Spree::Order.sum(:total).to_f}"
  end

  task validate: :environment do
    begin
      # Required properties
      shipping_weight_id = Spree::Property.where(name: 'shipping_weight').first.id
      shipping_dimensions_id = Spree::Property.where(name: 'shipping_dimensions').first.id
      shipping_quantity_id = Spree::Property.where(name: 'shipping_quantity').first.id

      fail "ERROR: shipping_weight_id is nil" if shipping_weight_id.nil?
      fail "ERROR: shipping_dimensions_id is nil" if shipping_weight_id.nil?
      fail "ERROR: shipping_quantity_id is nil" if shipping_weight_id.nil?

      products = Spree::Product.all
      products.each do |p|
        property = p.product_properties.where(property_id: shipping_weight_id).first
        puts "#{prod_desc(p)} - Shipping Weight is nil" if property.nil?

        property = p.product_properties.where(property_id: shipping_dimensions_id).first
        puts "#{prod_desc(p)} - Shipping Dimensions is nil" if property.nil?

        property = p.product_properties.where(property_id: shipping_quantity_id).first
        puts "#{prod_desc(p)} - Shipping Quantity is nil" if property.nil?
      end
    rescue => e
      puts("ERROR: #{e.message}")
    end
  end
end
