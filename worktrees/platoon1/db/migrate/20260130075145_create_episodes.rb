class CreateEpisodes < ActiveRecord::Migration[8.1]
  def change
    create_table :episodes do |t|
      t.references :novel, null: false, foreign_key: true
      t.references :chapter, null: true, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.integer :episode_number, null: false
      t.datetime :published_at
      t.integer :word_count, default: 0, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :episodes, :episode_number
    add_index :episodes, :published_at
  end
end
