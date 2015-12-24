def prod_desc(p)
  "#{p.id}:#{p.sku}:#{p.name}"
end

namespace :product do
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
        puts "Processed:#{product_processed} of #{product_count}, (%#{(100 * (product_processed.to_f / product_count.to_f)).round(4)})" if (product_processed % 10 ) == 0
      end
      after_count = Spree::Product.where(state: 'invalid').count
      puts "Product invalid before: #{before_count}"
      puts "Product invalid after: #{after_count}"
    rescue => e
      puts("ERROR: #{e.message}")
    end
  end
end
