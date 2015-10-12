module ReviewRating
  @queue = :review_rating

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.review_rating(@auction).deliver
  end   
end