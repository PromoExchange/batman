namespace :scheduler do
  task trigger_delivered_event: :environment do
    Spree::Auction.where(state: 'send_for_delivery').each { |a| a.delivered! if a.product_delivered? }
  end

  task ach_account_status: :environment do
    Spree::AuctionPayment.where(status: 'pending').each do |auction_payment|
      charge = Stripe::Charge.retrieve(auction_payment.charge_id)
      unless charge.status == 'pending'
        auction_payment.update_attributes(
          status: charge.status,
          failure_code: charge.failure_code,
          failure_message: charge.failure_message
        )
        BuyerMailer.ach_account_status(auction_payment).deliver
      end

      next unless charge.status == 'failed'

      auction_payment
        .bid
        .create_payment(
          Spree::User.find(auction_payment.bid.auction.buyer.id).customers.where(status: 'cc').last.token
        )
    end
  end

  task recalc_price_cache: :environment do
    Spree::CompanyStore.all.each do |company_store|
      Spree::Product.where(supplier: company_store.supplier).each do |product|
        Spree::PriceCache.where(product: product).destroy_all
        product.refresh_price_cache
      end
    end
  end
end
