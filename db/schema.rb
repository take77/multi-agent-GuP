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

ActiveRecord::Schema[8.1].define(version: 2026_01_30_123006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "character_relationships", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "intensity"
    t.bigint "novel_id", null: false
    t.bigint "related_character_id", null: false
    t.string "relationship_type", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "related_character_id"], name: "idx_char_rel_unique_pair", unique: true
    t.index ["character_id"], name: "index_character_relationships_on_character_id"
    t.index ["novel_id"], name: "index_character_relationships_on_novel_id"
    t.index ["related_character_id"], name: "index_character_relationships_on_related_character_id"
  end

  create_table "character_states", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.string "emotional_state"
    t.bigint "episode_id", null: false
    t.jsonb "inventory", default: []
    t.text "knowledge"
    t.string "location"
    t.text "notes"
    t.string "physical_state"
    t.datetime "updated_at", null: false
    t.index ["character_id", "episode_id"], name: "index_character_states_on_character_id_and_episode_id", unique: true
    t.index ["character_id"], name: "index_character_states_on_character_id"
    t.index ["episode_id"], name: "index_character_states_on_episode_id"
  end

  create_table "characters", force: :cascade do |t|
    t.text "abilities"
    t.integer "age"
    t.text "appearance"
    t.text "background"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "novel_id", null: false
    t.text "personality"
    t.string "role"
    t.text "speech_style"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_characters_on_name"
    t.index ["novel_id"], name: "index_characters_on_novel_id"
  end

  create_table "foreshadowings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "importance", default: 1, null: false
    t.bigint "novel_id", null: false
    t.integer "planned_resolution_episode"
    t.bigint "planted_episode_id"
    t.bigint "resolved_episode_id"
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["importance"], name: "index_foreshadowings_on_importance"
    t.index ["novel_id"], name: "index_foreshadowings_on_novel_id"
    t.index ["status"], name: "index_foreshadowings_on_status"
  end

  create_table "relationship_logs", force: :cascade do |t|
    t.text "change_description"
    t.bigint "character_relationship_id", null: false
    t.datetime "created_at", null: false
    t.bigint "episode_id", null: false
    t.integer "new_intensity"
    t.string "new_type"
    t.integer "previous_intensity"
    t.string "previous_type"
    t.datetime "updated_at", null: false
    t.index ["character_relationship_id"], name: "idx_rel_logs_on_char_rel_id"
    t.index ["episode_id"], name: "index_relationship_logs_on_episode_id"
  end

  create_table "world_settings", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.jsonb "details", default: {}
    t.bigint "novel_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_world_settings_on_category"
    t.index ["novel_id"], name: "index_world_settings_on_novel_id"
  end
end
