class AddUniqueIndexToEpisodesNovelIdEpisodeNumber < ActiveRecord::Migration[8.1]
  def change
    add_index :episodes, [:novel_id, :episode_number], unique: true
  end
end
