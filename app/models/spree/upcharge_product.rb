class Spree::UpchargeProduct < Spree::Upcharge
  belongs_to :product, foreign_key: 'related_id'
  belongs_to :imprint_method
end
