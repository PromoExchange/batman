module WaitingForConfirmation
  @queue = :seller_invite

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.waiting_for_confirmation(@auction).deliver
    Resque.enqueue_at(1.days.from_now, UnpaidInvoice, auction_id)
  end
end
