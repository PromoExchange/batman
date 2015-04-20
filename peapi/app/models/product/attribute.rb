# create_table "product_attributes", force: :cascade do |t|
#   t.string   "name"
#   t.string   "value"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
# end
class Product::Attribute < ActiveRecord::Base
  validates :name, presence: true
  validates :value, presence: true
end
