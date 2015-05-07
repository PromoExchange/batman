class SizeProduct < ActiveRecord::Base
  # TODO: Reverse this table name to match others
  self.table_name = 'products_sizes'

  validates :size_id, presence: true
  validates :product_id, presence: true

  belongs_to :size
  belongs_to :product
end
