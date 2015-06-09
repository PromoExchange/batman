class Spree::Prebid < ActiveRecord::Base
  belongs_to :seller, class_name: 'User'
  has_many :adjustments
  has_many :bids

  validates :seller_id, presence: true
end
