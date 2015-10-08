module ProofAvailable
  @queue = :proof_available
  
  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    if @auction.waiting_proof_approval?
      BuyerMailer.proof_available(@auction).deliver
      Resque.enqueue_at(Time.zone.now.tomorrow, ProofAvailable, auction_id: @auction.id)
    end
  end
end