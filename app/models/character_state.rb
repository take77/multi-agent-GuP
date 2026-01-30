# frozen_string_literal: true

class CharacterState < ApplicationRecord
  # === Associations ===
  belongs_to :character
  # belongs_to :episode  # 第1中隊担当。揃い次第有効化。

  # === Validations ===
  validates :character_id, presence: true
  validates :episode_id, presence: true
  validates :character_id, uniqueness: { scope: :episode_id }
end
