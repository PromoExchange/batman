# == Schema Information
#
# Table name: keywords_products
#
#  product_id :integer          not null
#  keyword_id :integer          not null
#
# Indexes
#
#  index_keywords_products_on_keyword_id  (keyword_id)
#  index_keywords_products_on_product_id  (product_id)
#

class KeywordProduct < ActiveRecord::Base
  self.table_name = 'keywords_products'

  validates :keyword_id, presence: true
  validates :product_id, presence: true

  belongs_to :keyword
  belongs_to :product
end
