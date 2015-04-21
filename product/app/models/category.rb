# create_table "categories", force: :cascade do |t|
#   t.string   "name"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.integer  "parent_id"
# end

class Category < ActiveRecord::Base
  validates :name, presence: true
  validates :related_id, presence: true
end
