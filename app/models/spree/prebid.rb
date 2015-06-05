class Spree::Prebid < ActiveRecord::Base
  belongs_to :seller, class_name: 'User'
  belongs_to :taxon
  has_many :adjustments, as: :adjustable
  has_many :bids

  validates :taxon_id, presence: true
  validates :seller_id, presence: true
end
