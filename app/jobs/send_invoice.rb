module SendInvoice
  @queue = :send_invoices

  def self.perform(auction)
    @auction = Spree::Auction.find(auction['auction_id'])
    SellerMailer.initial_invoice(@auction).deliver
  end
end
