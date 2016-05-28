module UnpaidInvoice
  @queue = :unpaid_invoice

  def self.perform(auction_id)
    @auction = Spree::Auction.find(auction_id)
    if @auction.unpaid?
      SellerMailer.invoice_not_paid(@auction.winning_bid.seller)
      Resque.enqueue_at(EmailHelper.email_delay(3.days.from_now), UnpaidInvoice, @auction.id)
    end
  end
end
