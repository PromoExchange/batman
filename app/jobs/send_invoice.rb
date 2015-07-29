module SendInvoice
  @queue = :send_invoices

  def self.perform(auction)
    @auction = Spree::Auction.find(auction['auction_id'])
    SellerEmail.initial_invoice(@auction)
  end
end
