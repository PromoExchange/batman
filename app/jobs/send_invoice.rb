module SendInvoice
  @queue = :send_invoice

  def self.perform(params)
    @purchase = Spree::Purchase.find_by_order_id(params['order_id'])
    @payment_email = params['payment_email']
    SellerMailer.invoice(@purchase, @payment_email).deliver
    BuyerMailer.invoice(@purchase, @payment_email).deliver
  end
end
