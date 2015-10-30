class Spree::Customer < Spree::Base
  belongs_to :user

  scope :web_check, -> { where(payment_type: 'wc') }
  scope :credit_card, -> { where(payment_type: 'cc') }
  scope :verified, -> { where(status: 'verified') }
end