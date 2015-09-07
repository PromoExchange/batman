module SellerInvite
  @queue = :seller_invite

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.seller_invite(@auction, params['type'], params['email_address']).deliver
  end
end
