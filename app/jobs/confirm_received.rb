module ConfirmReceived
  @queue = :confirm_received

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.confirm_received(@auction).deliver
  end
end
