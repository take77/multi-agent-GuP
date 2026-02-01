class CreateChapters < ActiveRecord::Migration[8.1]
  def change
    create_table :chapters do |t|
      t.references :novel, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :chapter_number, null: false
      t.text :synopsis

      t.timestamps
    end

    add_index :chapters, :chapter_number
    add_index :chapters, [:novel_id, :chapter_number], unique: true
  end
end
