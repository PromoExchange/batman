class Spree::Message < Spree::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :from, class_name: 'User'
  belongs_to :to, class_name: 'User'
  belongs_to :product, class_name: 'Product'

  MESSAGE_STATUSES = %w(unread read deleted).freeze

  validates :owner_id, presence: true
  validates :from_id, presence: true
  validates :to_id, presence: true
  validates :status, inclusion: { in: MESSAGE_STATUSES }
  validates :product_id, presence: true

  def self.user_messages
    Spree::Auctions.where(buyer_id: current_spree_user.id)
  end
end
