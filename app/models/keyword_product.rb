class KeywordProduct < ActiveRecord::Base
  self.table_name = 'keywords_products'

  validates :keyword_id, presence: true
  validates :product_id, presence: true

  belongs_to :keyword
  belongs_to :product
end
