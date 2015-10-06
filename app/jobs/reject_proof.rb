module RejectProof
  @queue = :reject_proof

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.reject_proof(@auction).deliver
  end
end