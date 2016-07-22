class Spree::AuctionPayment < ActiveRecord::Base
  belongs_to :bid
  belongs_to :request_idea

  validates :bid_id, presence: true

  def charge
    @charge ||= Stripe::Charge.retrieve(charge_id)
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(number: "111111111111#{charge.last4}")
  end
end
