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
FactoryGirl.define do
  factory :product_detail, :class => 'Product::Detail' do
    name "name"
    desc "desc"
    imageurl ""
    price 0.00
    overview ""
    detail ""
    production_time ""
    imprint_lines ""
  end

end
