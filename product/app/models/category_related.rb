# create_table "category_related", force: :cascade do |t|
#   t.integer "category_id", null: false
#   t.integer "related_id",  null: false
# end

class CategoryRelated < ActiveRecord::Base
  self.table_name = "category_related"
  validates :category_id, presence: true
  validates :related_id, presence: true
end
