module InProduction
  @queue = :in_production

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    BuyerMailer.in_production(@auction).deliver
  end
end
