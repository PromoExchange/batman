Spree::User.class_eval do
  has_many :logos
  has_many :tax_rates
  has_many :addresses
  has_many :review
  has_many :product_requests, foreign_key: 'buyer_id'
  has_many :customers

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

  def stars
    avg_rating.to_f || 0
  end

  def recalculate_rating
    self[:reviews_count] = review.reload.approved.count
    if reviews_count > 0
      self[:avg_rating] = review.approved.sum(:rating).to_f / reviews_count
    else
      self[:avg_rating] = 0
    end
    save
  end
end
