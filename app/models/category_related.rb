# == Schema Information
#
# Table name: category_related
#
#  id          :integer          not null, primary key
#  category_id :integer          not null
#  related_id  :integer          not null
#
# Indexes
#
#  index_category_related_on_category_id  (category_id)
#  index_category_related_on_related_id   (related_id)
#

class CategoryRelated < ActiveRecord::Base
  self.table_name = 'category_related'

  validates :category_id, presence: true
  validates :related_id, presence: true

  belongs_to :category, foreign_key: 'category_id', class_name: 'Category'
  belongs_to :related, foreign_key: 'related_id', class_name: 'Category'
end
