module SendInvoice
  @queue = :send_invoice

  def self.perform(params)
    @purchase = Spree::Purchase.find_by_order_id(params['order_id'])
    SellerMailer.invoice(@purchase).deliver
    BuyerMailer.invoice(@purchase).deliver
    # TODO: Send quote messages to PX folk
  end
end
