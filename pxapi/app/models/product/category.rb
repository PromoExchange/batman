# create_table "product_categories", force: :cascade do |t|
#   t.string   "name"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
# end

class Product::Category < ActiveRecord::Base
  validates :name, presence: true
end
