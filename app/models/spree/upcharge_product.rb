class Spree::UpchargeProduct < Spree::Upcharge
  after_save :clear_cache

  belongs_to :product, foreign_key: 'related_id'
  belongs_to :imprint_method

  delegate :clear_cache, to: :product
end
