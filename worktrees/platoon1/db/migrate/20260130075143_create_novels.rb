class CreateNovels < ActiveRecord::Migration[8.1]
  def change
    create_table :novels do |t|
      t.string :title, null: false
      t.text :synopsis
      t.integer :genre, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.references :user, null: false, foreign_key: true
      t.string :cover_image_url
      t.datetime :published_at
      t.integer :total_episodes, default: 0, null: false

      t.timestamps
    end

    add_index :novels, :genre
    add_index :novels, :status
    add_index :novels, :published_at
  end
end
