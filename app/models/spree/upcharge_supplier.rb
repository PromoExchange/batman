class Spree::UpchargeSupplier < Spree::Upcharge
  has_one :supplier, foreign_key: 'related_id'
end
