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

ActiveRecord::Schema[8.1].define(version: 2026_01_30_100041) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chapters", force: :cascade do |t|
    t.integer "chapter_number", null: false
    t.datetime "created_at", null: false
    t.bigint "novel_id", null: false
    t.text "synopsis"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_number"], name: "index_chapters_on_chapter_number"
    t.index ["novel_id", "chapter_number"], name: "index_chapters_on_novel_id_and_chapter_number", unique: true
    t.index ["novel_id"], name: "index_chapters_on_novel_id"
  end

  create_table "episodes", force: :cascade do |t|
    t.text "body"
    t.bigint "chapter_id"
    t.datetime "created_at", null: false
    t.integer "episode_number", null: false
    t.bigint "novel_id", null: false
    t.datetime "published_at"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "word_count", default: 0, null: false
    t.index ["chapter_id"], name: "index_episodes_on_chapter_id"
    t.index ["episode_number"], name: "index_episodes_on_episode_number"
    t.index ["novel_id", "episode_number"], name: "index_episodes_on_novel_id_and_episode_number", unique: true
    t.index ["novel_id"], name: "index_episodes_on_novel_id"
    t.index ["published_at"], name: "index_episodes_on_published_at"
  end

  create_table "novels", force: :cascade do |t|
    t.string "cover_image_url"
    t.datetime "created_at", null: false
    t.integer "genre", default: 0, null: false
    t.datetime "published_at"
    t.integer "status", default: 0, null: false
    t.text "synopsis"
    t.string "title", null: false
    t.integer "total_episodes", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["genre"], name: "index_novels_on_genre"
    t.index ["published_at"], name: "index_novels_on_published_at"
    t.index ["status"], name: "index_novels_on_status"
    t.index ["user_id"], name: "index_novels_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "chapters", "novels"
  add_foreign_key "episodes", "chapters"
  add_foreign_key "episodes", "novels"
  add_foreign_key "novels", "users"
end
