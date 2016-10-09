class Spree::UpchargeSupplier < Spree::Upcharge
  after_save :clear_cache
  has_one :supplier, foreign_key: 'related_id'

  def clear_cache
    Spree::Product.where(origin_supplier_id: supplier.id).find_each(&:clear_cache)
  end
end
