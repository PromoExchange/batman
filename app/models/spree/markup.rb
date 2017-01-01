class Spree::Markup < Spree::Base
  after_save :clear_cache

  belongs_to :supplier
  belongs_to :company_store

  validates :supplier_id, presence: true
  validates :company_store_id, presence: true
  validates :markup, presence: true

  def clear_cache
    company_store.products.each(&:clear_cache)
  end
end
