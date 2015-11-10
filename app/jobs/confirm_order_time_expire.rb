module ConfirmOrderTimeExpire
  @queue = :confirm_time_expire

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    if @auction.waiting_confirmation?
      SellerMailer.confirm_order_time_expire(@auction).deliver
      BuyerMailer.confirm_order_expire(@auction).deliver
      @auction.no_confirm_late!
      @auction.winning_bid.reject!
    end
  end
end
