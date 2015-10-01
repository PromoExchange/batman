module ConfirmReceiptReminder
  @queue = :confirm_receipt_reminder

  def self.perform(params)
    @auction = Spree::Auction.find(params['auction_id'])
    BuyerMailer.confirm_receipt_reminder(@auction).deliver
  end
end
