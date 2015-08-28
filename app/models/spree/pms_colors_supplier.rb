class Spree::PmsColorsSupplier < Spree::Base
  belongs_to :supplier
  belongs_to :pms_color
  belongs_to :imprint_method

  validates :supplier_id, presence: true
  validates :pms_color_id, presence: true
end
