class Episode < ApplicationRecord
  belongs_to :novel
  belongs_to :chapter, optional: true

  enum :status, {
    draft: 0,
    published: 1,
    archived: 2
  }

  validates :title, presence: true
  validates :episode_number, presence: true,
                             numericality: { only_integer: true, greater_than: 0 },
                             uniqueness: { scope: :novel_id }
end
