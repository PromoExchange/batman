module ConfirmOrderTimeExpire
  @queue = :confirm_time_expire

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.confirm_order_time_expire(@auction).deliver if @auction.waiting_confirmation?
    @auction.no_confirm_late!
  end
end
