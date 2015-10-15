module NewRequestIdea
  @queue = :new_request_idea

  def self.perform(params)
    @product_request = Spree::ProductRequest.find(params['product_request_id'])
    BuyerMailer.new_request_idea(@product_request).deliver
  end
end
