# frozen_string_literal: true

class CreateRelationshipLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :relationship_logs do |t|
      t.bigint :character_relationship_id, null: false
      # episodes テーブルは第1中隊担当。外部キー制約なしでカラムのみ作成。
      t.bigint :episode_id, null: false

      t.text :change_description
      t.string :previous_type
      t.string :new_type
      t.integer :previous_intensity
      t.integer :new_intensity

      t.timestamps
    end

    add_index :relationship_logs, :character_relationship_id, name: "idx_rel_logs_on_char_rel_id"
    add_index :relationship_logs, :episode_id
  end
end
