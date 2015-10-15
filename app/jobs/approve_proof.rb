module ApproveProof
  @queue = :approve_proof

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.approve_proof(@auction).deliver
  end
end
