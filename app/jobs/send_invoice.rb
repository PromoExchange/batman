module SendInvoice
  @queue = :send_invoice

  def self.perform(auction_id)
    @auction = Spree::Auction.find(auction_id)
    SellerMailer.invoice(@auction).deliver
    BuyerMailer.invoice(@auction).deliver
  end
end
