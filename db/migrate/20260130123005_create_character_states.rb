# frozen_string_literal: true

class CreateCharacterStates < ActiveRecord::Migration[8.1]
  def change
    create_table :character_states do |t|
      t.bigint :character_id, null: false
      # episodes テーブルは第1中隊担当。外部キー制約なしでカラムのみ作成。
      t.bigint :episode_id, null: false

      t.string :location
      t.string :emotional_state
      t.string :physical_state
      t.text :knowledge
      t.jsonb :inventory, default: []
      t.text :notes

      t.timestamps
    end

    add_index :character_states, :character_id
    add_index :character_states, :episode_id
    add_index :character_states, %i[character_id episode_id], unique: true
  end
end
