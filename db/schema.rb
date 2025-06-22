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

ActiveRecord::Schema[8.0].define(version: 2025_06_22_213605) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "black_listed_tokens", force: :cascade do |t|
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "jti", null: false
  end

  create_table "jti_registries", primary_key: "jti", id: :uuid, default: nil, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jti_registries_on_jti", unique: true
    t.index ["user_id"], name: "index_jti_registries_on_user_id"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.string "crypted_token", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "jti", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmation_token_expires_at"
    t.datetime "reset_password_token_expires_at"
    t.index ["email"], name: "unique_emails", unique: true
  end

  add_foreign_key "black_listed_tokens", "jti_registries", column: "jti", primary_key: "jti"
  add_foreign_key "jti_registries", "users"
  add_foreign_key "refresh_tokens", "jti_registries", column: "jti", primary_key: "jti"
end
