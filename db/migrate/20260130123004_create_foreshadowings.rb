# frozen_string_literal: true

class CreateForeshadowings < ActiveRecord::Migration[8.1]
  def change
    create_table :foreshadowings do |t|
      t.bigint :novel_id, null: false

      t.string :title, null: false
      t.text :description
      # episodes テーブルは第1中隊担当。外部キー制約なしでカラムのみ作成。
      t.bigint :planted_episode_id
      t.bigint :resolved_episode_id
      t.integer :planned_resolution_episode
      t.integer :status, null: false, default: 0
      t.integer :importance, null: false, default: 1

      t.timestamps
    end

    add_index :foreshadowings, :novel_id
    add_index :foreshadowings, :status
    add_index :foreshadowings, :importance
  end
end
