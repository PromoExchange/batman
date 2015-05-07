# == Schema Information
#
# Table name: lines_products
#
#  product_id :integer          not null
#  line_id    :integer          not null
#
# Indexes
#
#  index_lines_products_on_line_id     (line_id)
#  index_lines_products_on_product_id  (product_id)
#

class LineProduct < ActiveRecord::Base
  self.table_name = 'lines_products'

  validates :line_id, presence: true
  validates :product_id, presence: true

  belongs_to :line
  belongs_to :product
end
