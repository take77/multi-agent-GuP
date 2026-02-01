class Chapter < ApplicationRecord
  belongs_to :novel
  has_many :episodes, dependent: :nullify

  validates :title, presence: true
  validates :chapter_number, presence: true,
                             numericality: { only_integer: true, greater_than: 0 },
                             uniqueness: { scope: :novel_id }
end
