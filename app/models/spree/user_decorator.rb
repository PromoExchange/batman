Spree::User.class_eval do
  has_many :logos
  has_many :tax_rates
  has_many :addresses

  def ban
    Spree::Bid.destroy_all(seller_id: id, status: :open)
    update_attribute(:banned, true)
  end

  def unban
    update_attribute(:banned, false)
  end
end
