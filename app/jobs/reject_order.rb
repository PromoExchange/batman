module RejectOrder
  @queue = :reject_order

  def self.perform(params)
    auction_id = params['auction_id']
    rejection_reason = params['rejection_reason']
    SellerMailer.reject_order(auction_id, rejection_reason).deliver
  end
end
