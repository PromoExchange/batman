module UnpaidInvoice
  @queue = :unpaid_invoice

  def self.perform(auction_id)
    SellerEmail.invoice_not_paid(Spree::Auction.find(auction_id).seller)
    Resque.enqueue_at(EmailHelpers.email_delay(3.days.from_now), UnpaidInvoice, auction_id)
  end
end
