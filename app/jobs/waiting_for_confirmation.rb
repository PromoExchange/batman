module WaitingForConfirmation
  @queue = :waiting_confirmation

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    SellerMailer.waiting_for_confirmation(@auction).deliver
  end

  def self.after_perform(*_args)
    ActiveRecord::Base.connection.disconnect!
  end
end
