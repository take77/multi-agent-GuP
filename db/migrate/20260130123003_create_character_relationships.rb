# frozen_string_literal: true

class CreateCharacterRelationships < ActiveRecord::Migration[8.1]
  def change
    create_table :character_relationships do |t|
      t.bigint :novel_id, null: false
      t.bigint :character_id, null: false
      t.bigint :related_character_id, null: false

      t.string :relationship_type, null: false
      t.text :description
      t.integer :intensity

      t.timestamps
    end

    add_index :character_relationships, :novel_id
    add_index :character_relationships, :character_id
    add_index :character_relationships, :related_character_id
    add_index :character_relationships, %i[character_id related_character_id],
              unique: true, name: "idx_char_rel_unique_pair"
  end
end
