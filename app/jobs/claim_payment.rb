module ClaimPayment
  @queue = :claim_payment

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.claim_payment(@auction).deliver
    Resque.enqueue_at(
      EmailHelpers.email_delay(Time.zone.now + 1.days),
      ClaimPayment,
      auction_id: id
    )
  end
end
