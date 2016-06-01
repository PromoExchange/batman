class Spree::ShippingOption < ActiveRecord::Base
  belongs_to :bid

  validates :name, presence: true
  validates :bid_id, presence: true
  validates :delta, presence: true
end
