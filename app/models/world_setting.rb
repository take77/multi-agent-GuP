# frozen_string_literal: true

class WorldSetting < ApplicationRecord
  # === Associations ===
  # belongs_to :novel  # 第1中隊担当。揃い次第有効化。

  # === Constants ===
  CATEGORIES = %w[geography magic culture history politics].freeze

  # === Validations ===
  validates :novel_id, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :title, presence: true
end
