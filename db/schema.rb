# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150429132939) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brands", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_related", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "related_id",  null: false
  end

  create_table "colors", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "colors_products", id: false, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "color_id",   null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string   "code_2",       null: false
    t.string   "code_3",       null: false
    t.string   "short_name",   null: false
    t.string   "code_numeric", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "images", force: :cascade do |t|
    t.string   "title"
    t.string   "location",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imagetypes", force: :cascade do |t|
    t.integer  "image_id",   null: false
    t.integer  "product_id", null: false
    t.string   "sizetype",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keywords", force: :cascade do |t|
    t.string   "word",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keywords_products", id: false, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "keyword_id", null: false
  end

  create_table "lines", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "brand_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lines_products", id: false, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "line_id",    null: false
  end

  create_table "materials", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "materials_products", id: false, force: :cascade do |t|
    t.integer "product_id",  null: false
    t.integer "material_id", null: false
  end

  create_table "media_references", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "location",   null: false
    t.string   "reference",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "media_references_products", id: false, force: :cascade do |t|
    t.integer "product_id",         null: false
    t.integer "media_reference_id", null: false
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "uid",          null: false
    t.string   "secret",       null: false
    t.text     "redirect_uri", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "prices", force: :cascade do |t|
    t.integer  "value_cents",    default: 0,                     null: false
    t.string   "value_currency", default: "USD",                 null: false
    t.string   "pricetype",                                      null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "lower"
    t.string   "upper"
    t.datetime "effective_date", default: '2015-04-29 21:59:39', null: false
    t.string   "code"
  end

  create_table "prices_products", id: false, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "price_id",   null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "description",  null: false
    t.string   "includes"
    t.string   "features"
    t.integer  "packsize"
    t.string   "packweight"
    t.string   "unit_measure"
    t.string   "leadtime"
    t.string   "rushtime"
    t.string   "info"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "supplier_id",  null: false
  end

  create_table "products_sizes", id: false, force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "size_id",    null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sizes", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "width"
    t.string   "height"
    t.string   "depth"
    t.string   "dia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name",        null: false
    t.string "description"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
