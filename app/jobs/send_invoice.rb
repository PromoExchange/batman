module SendInvoice
  @queue = :send_invoice

  def self.perform(params)
    @auction = Spree::Auction.find(params[:auction_id])
    SellerMailer.invoice(@auction).deliver
    BuyerMailer.invoice(@auction).deliver
  end
end
