module ConfirmOrderTimeExpire
  @queue = :confirm_time_expire

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.confirm_order_time_expire(@auction).deliver
  end
end
