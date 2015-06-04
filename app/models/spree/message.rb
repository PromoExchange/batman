module Spree
  class Message < Spree::Base
    validates :owner_id, presence: true
    validates :from_id, presence: true
    validates :to_id, presence: true
    validates :status, inclusion: { in: %w(unread read deleted) }

    def self.user_messages
      Spree::Auctions.where(buyer_id: current_spree_user.id)
    end
  end
end
