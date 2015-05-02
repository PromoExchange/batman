# == Schema Information
#
# Table name: category_related
#
#  id          :integer          not null, primary key
#  category_id :integer          not null
#  parent_id   :integer          not null
#
# Indexes
#
#  index_category_related_on_category_id  (category_id)
#  index_category_related_on_parent_id    (parent_id)
#

class CategoryRelated < ActiveRecord::Base
  self.table_name = 'category_related'

  validates :category_id, presence: true
  validates :parent_id, presence: true

  belongs_to :category, foreign_key: 'category_id', class_name: 'Category'
  belongs_to :parent, foreign_key: 'parent_id', class_name: 'Category'
end
