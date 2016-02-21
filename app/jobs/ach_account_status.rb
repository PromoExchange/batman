module AchAccountStatus
  @queue = :ach_account_status

  def self.perform
    auction_payments = Spree::AuctionPayment.where(status: 'pending')
    auction_payments.each do |auction_payment|
      charge = Stripe::Charge.retrieve(auction_payment.charge_id)
      unless charge.status == 'pending'
        auction_payment.update_attributes(
          status: charge.status,
          failure_code: charge.failure_code,
          failure_message: charge.failure_message
        )
        BuyerMailer.ach_account_status(auction_payment).deliver
      end

      if charge.status == 'failed'
        user_id = auction_payment.bid.auction.buyer.id
        user = Spree::User.find(user_id)
        token = user.customers.where(status: 'cc').last.token
        auction_payment.bid.create_payment(token)
      end
    end
  end
end
