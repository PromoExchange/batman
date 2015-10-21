module IdeationRequest
  @queue = :ideation_request

  def self.perform(params)
    product_request = Spree::ProductRequest.find(params['request_id'])
    BuyerMailer.ideation_request(product_request).deliver
  end
end
