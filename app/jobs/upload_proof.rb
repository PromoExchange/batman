module UploadProof
  @queue = :upload_proof

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    BuyerMailer.upload_proof(@auction).deliver
  end
end
