class Spree::Carton < Spree::Base
  belongs_to :product
  validates :product_id, presence: true

  attr_writer :default_dimension

  def default_dimension
    @default_dimension ||= 12
  end

  def to_s
    "#{length || default_dimension}L x #{width || default_dimension}W x #{height || default_dimension}H"
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
