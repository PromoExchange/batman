# == Schema Information
#
# Table name: materials_products
#
#  product_id  :integer          not null
#  material_id :integer          not null
#
# Indexes
#
#  index_materials_products_on_material_id  (material_id)
#  index_materials_products_on_product_id   (product_id)
#

class MaterialProduct < ActiveRecord::Base
  self.table_name = 'materials_products'

  validates :material_id, presence: true
  validates :product_id, presence: true

  belongs_to :material
  belongs_to :product
end
