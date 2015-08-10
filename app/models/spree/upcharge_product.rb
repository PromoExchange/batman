class Spree::UpchargeProduct < Spree::Upcharge
  has_one :product, foreign_key: 'related_id'
end
