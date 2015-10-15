module SellerFailedUploadProof
  @queue = :seller_failed_upload_proof

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.seller_failed_upload_proof(@auction).deliver if @auction.create_proof?
  end
end
