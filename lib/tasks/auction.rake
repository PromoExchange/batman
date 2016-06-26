namespace :auction do
  desc 'send tracking information to buyer'
  task :send_tracking_info, [:auction_id, :tracking_number] => :environment do
    auction = Spree::Auction.find args[:auction_id]
    auction.update_attribute tracking_number: args[:tracking_number]

    Resque.enqueue(SendTrackingInfo, auction_id: auction.id)
  end
end
