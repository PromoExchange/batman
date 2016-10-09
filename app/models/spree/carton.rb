class Spree::Carton < Spree::Base
  after_save :clear_cache

  belongs_to :product
  validates :product_id, presence: true

  delegate :clear_cache, to: :product

  DEFAULT_DIMENSION = 12

  def to_s
    "#{length || DEFAULT_DIMENSION}L x #{width || DEFAULT_DIMENSION}W x #{height || DEFAULT_DIMENSION}H"
  end

  def active?
    return true if fixed_price.present?
    length.present? &&
      width.present? &&
      height.present? &&
      quantity.present? &&
      quantity > 0 &&
      weight.present? &&
      originating_zip.present?
  end
end
