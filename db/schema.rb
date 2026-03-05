# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_05_000400) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "brands", force: :cascade do |t|
    t.string "country"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brands_on_name", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "extracted_text"
    t.datetime "updated_at", null: false
  end

  create_table "prices", force: :cascade do |t|
    t.integer "brand_id", null: false
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "product_id", null: false
    t.integer "quality_id", null: false
    t.string "unit"
    t.integer "unit_quantity"
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 10, scale: 2, null: false
    t.index ["brand_id"], name: "index_prices_on_brand_id"
    t.index ["product_id", "brand_id", "quality_id", "unit", "unit_quantity", "date"], name: "index_prices_on_product_brand_quality_unit_date"
    t.index ["product_id"], name: "index_prices_on_product_id"
    t.index ["quality_id"], name: "index_prices_on_quality_id"
  end

  create_table "product_aliases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_product_aliases_on_name", unique: true
    t.index ["product_id"], name: "index_product_aliases_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "normalized_name", null: false
    t.datetime "updated_at", null: false
    t.index ["normalized_name"], name: "index_products_on_normalized_name", unique: true
  end

  create_table "qualities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "level", null: false
    t.decimal "quality_factor", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.index ["level"], name: "index_qualities_on_level", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "prices", "brands"
  add_foreign_key "prices", "products"
  add_foreign_key "prices", "qualities"
  add_foreign_key "product_aliases", "products"
end
