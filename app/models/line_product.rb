class LineProduct < ActiveRecord::Base
  self.table_name = 'lines_products'

  validates :line_id, presence: true
  validates :product_id, presence: true

  belongs_to :line
  belongs_to :product
end
