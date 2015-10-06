module ClaimPaymentRequest
  @queue = :claim_payment_request

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.claim_payment_request(params, @auction).deliver
  end
end
