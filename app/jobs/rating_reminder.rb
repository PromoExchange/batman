module RatingReminder
  @queue = :rating_reminder

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    BuyerMailer.rating_reminder(@auction).deliver unless @auction.reviewed?
  end
end
