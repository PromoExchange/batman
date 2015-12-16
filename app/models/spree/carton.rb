class Spree::Carton < Spree::Base
  belongs_to :product
  validates :product_id, presence: true

  def to_s
    return "#{length}L X #{width}W X #{height}H" if length.present?
    ""
  end
end
