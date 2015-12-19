class Spree::Carton < Spree::Base
  belongs_to :product
  validates :product_id, presence: true

  def to_s
    return "#{length}L x #{width}W x #{height}H" if length.present?
    ''
  end

  def active?
    length.present? &&
      width.present? &&
      height.present? &&
      quantity > 0 &&
      weight.present? &&
      originating_zip.present?
  end
end
