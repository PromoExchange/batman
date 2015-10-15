module SampleRequest
  @queue = :sample_request

  def self.perform(params)
    @request_idea = Spree::RequestIdea.find(params['request_idea_id'])
    BuyerMailer.sample_request(@request_idea).deliver
  end
end
