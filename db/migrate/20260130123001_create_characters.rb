# frozen_string_literal: true

class CreateCharacters < ActiveRecord::Migration[8.1]
  def change
    create_table :characters do |t|
      # novels テーブルは第1中隊が担当のため、外部キー制約なしでカラムのみ作成。
      t.bigint :novel_id, null: false

      t.string :name, null: false
      t.integer :age
      t.text :appearance
      t.text :abilities
      t.text :personality
      t.text :speech_style
      t.text :background
      t.string :role

      t.timestamps
    end

    add_index :characters, :novel_id
    add_index :characters, :name
  end
end
