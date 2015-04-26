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

ActiveRecord::Schema.define(version: 20150426112513) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brands", force: :cascade do |t|
    t.string   "brand",      null: false
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

  create_table "lines", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "brand_id",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "materials", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "media_references", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "location",   null: false
    t.string   "reference",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "prices", force: :cascade do |t|
    t.integer  "value_cents",    default: 0,                     null: false
    t.string   "value_currency", default: "USD",                 null: false
    t.string   "pricetype",                                      null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "lower"
    t.string   "upper"
    t.datetime "effective_date", default: '2015-04-26 11:22:00', null: false
    t.string   "code"
  end

  create_table "sizes", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "width"
    t.string   "height"
    t.string   "depth"
    t.string   "dia"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
