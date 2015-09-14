Spree::Address.class_eval do
  has_one :bill_user, class_name: 'User', foreign_key: 'bill_address_id'
  has_one :ship_user, class_name: 'User', foreign_key: 'ship_address_id'
  belongs_to :user
  validates :company, presence: true
  
  alias_attribute :is_bill, :bill?
  alias_attribute :is_ship, :ship?

  def self.active
    where( deleted_at: nil )
  end

  def ship?
    ship_user.present?
  end

  def bill?
    bill_user.present?
  end

  def assign_user
    if ship_user.present?
      update(user_id: ship_user.id)
    else
      update(user_id: bill_user.id)
    end
  end
end
