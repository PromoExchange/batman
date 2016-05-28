module ProofNeededImmediately
  @queue = :proof_needed_immediately

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    if @auction.create_proof?
      SellerMailer.proof_needed_immediately(@auction).deliver
      Resque.enqueue_at(
        EmailHelper.email_delay(Time.zone.now.tomorrow),
        ProofNeededImmediately,
        auction_id: @auction.id
      )
    end
  end
end
