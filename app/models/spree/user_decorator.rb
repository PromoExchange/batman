Spree::User.class_eval do
  has_many :logos
  has_many :tax_rates
  has_many :addresses

  def ban
    cancel_bids
    update_attribute(:banned, true)
  end

  def unban
    update_attribute(:banned, false)
  end

  def cancel_bids
    Spree::Bid.where(seller_id: id, state: 'open').map(&:cancel)
  end
end
