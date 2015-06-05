class Spree::Message < Spree::Base
  validates :owner_id, presence: true
  validates :from_id, presence: true
  validates :to_id, presence: true
  validates :status, inclusion: { in: %w(unread read deleted) }

  belongs_to :owner, class_name: 'User'
  belongs_to :from, class_name: 'User'
  belongs_to :to, class_name: 'User'

  def self.user_messages
    Spree::Auctions.where(buyer_id: current_spree_user.id)
  end
end
