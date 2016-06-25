module SendInvoice
  @queue = :send_invoice

  def self.perform(params)
    Rails.logger.info params
  end
end
