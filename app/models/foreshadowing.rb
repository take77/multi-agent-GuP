# frozen_string_literal: true

class Foreshadowing < ApplicationRecord
  # === Associations ===
  # belongs_to :novel             # 第1中隊担当。揃い次第有効化。
  # belongs_to :planted_episode, class_name: "Episode", optional: true
  # belongs_to :resolved_episode, class_name: "Episode", optional: true

  # === Enums ===
  enum :status, {
    planted:   0,
    hinted:    1,
    resolved:  2,
    abandoned: 3
  }

  enum :importance, {
    minor:    0,
    normal:   1,
    major:    2,
    critical: 3
  }, prefix: true

  # === Validations ===
  validates :novel_id, presence: true
  validates :title, presence: true
  validates :status, presence: true
  validates :importance, presence: true
end
