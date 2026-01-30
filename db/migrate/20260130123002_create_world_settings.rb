# frozen_string_literal: true

class CreateWorldSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :world_settings do |t|
      t.bigint :novel_id, null: false

      t.string :category, null: false
      t.string :title, null: false
      t.text :description
      t.jsonb :details, default: {}

      t.timestamps
    end

    add_index :world_settings, :novel_id
    add_index :world_settings, :category
  end
end
