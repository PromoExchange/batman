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
    self[:avg_rating] =
      if reviews_count > 0
        review.approved.sum(:rating).to_f / reviews_count
      else
        0
      end
    save
  end

  def shipping_name
    return shipping_address.full_name if shipping_address.present?
    ''
  end

  def shipping_company
    return shipping_address.company if shipping_address.present?
    ''
  end

  # Get the tax rate this user charges for a given address
  # Applicable to seller accounts only.
  def tax_rate(address)
    return 0.0 if address.nil?

    # tax_zone_id = Spree::ZoneMember
    #   .where(zoneable_id: address.state_id)
    #   .includes(:zone)
    #   .pluck('spree_zones.id').first

    tax_rate = tax_rates.find_by_zone_id(address.state.id)

    tax_rate.nil? ? 0.0 : tax_rate.amount.to_f
  end
end
