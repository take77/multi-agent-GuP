class Novel < ApplicationRecord
  belongs_to :user
  has_many :chapters, dependent: :destroy
  has_many :episodes, dependent: :destroy

  enum :genre, {
    fantasy: 0,
    romance: 1,
    mystery: 2,
    sf: 3,
    horror: 4,
    literary: 5,
    other: 6
  }

  enum :status, {
    draft: 0,
    published: 1,
    archived: 2
  }

  validates :title, presence: true
end
