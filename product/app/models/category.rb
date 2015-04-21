# create_table "categories", force: :cascade do |t|
#   t.string   "name"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
# end

class Category < ActiveRecord::Base
  validates :name, presence: true

  has_many :categoryrelated, :foreign_key => "category_id",
      :class_name => "CategoryRelated"

  has_many :related, :through => :categoryrelated
end
