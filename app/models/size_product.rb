# == Schema Information
#
# Table name: products_sizes
#
#  product_id :integer          not null
#  size_id    :integer          not null
#
# Indexes
#
#  index_products_sizes_on_product_id  (product_id)
#  index_products_sizes_on_size_id     (size_id)
#

class SizeProduct < ActiveRecord::Base
  # TODO: Reverse this table name to match others
  self.table_name = 'products_sizes'

  validates :size_id, presence: true
  validates :product_id, presence: true

  belongs_to :size
  belongs_to :product
end
