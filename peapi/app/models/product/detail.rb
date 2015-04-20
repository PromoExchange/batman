# create_table "product_details", force: :cascade do |t|
#   t.string   "name"
#   t.string   "desc"
#   t.string   "imageurl"
#   t.float    "price"
#   t.string   "overview"
#   t.string   "detail"
#   t.string   "production_time"
#   t.string   "imprint_lines"
#   t.datetime "created_at",      null: false
#   t.datetime "updated_at",      null: false
# end
class Product::Detail < ActiveRecord::Base
  validates :name, presence: true
  validates :price, presence: true
end
