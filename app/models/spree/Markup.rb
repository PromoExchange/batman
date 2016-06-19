class Spree::Markup < Spree::Base
  belongs_to :supplier
  belongs_to :company_store

  validates :supplier_id, presence: true
  validates :company_store_id, presence: true
  validates :markup, presence: true

  def eqp?
    eqp_discount != 0.0
  end
end
