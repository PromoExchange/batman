class MaterialProduct < ActiveRecord::Base
  self.table_name = 'materials_products'

  validates :material_id, presence: true
  validates :product_id, presence: true

  belongs_to :material
  belongs_to :product
end
