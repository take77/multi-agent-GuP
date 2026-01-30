# frozen_string_literal: true

class CharacterRelationship < ApplicationRecord
  # === Associations ===
  # belongs_to :novel  # 第1中隊担当。揃い次第有効化。
  belongs_to :character
  belongs_to :related_character, class_name: "Character"
  has_many :relationship_logs, dependent: :destroy

  # === Validations ===
  validates :novel_id, presence: true
  validates :character_id, presence: true
  validates :related_character_id, presence: true
  validates :relationship_type, presence: true
  validates :intensity, numericality: { only_integer: true, in: 1..10 }, allow_nil: true
  validates :character_id, uniqueness: { scope: :related_character_id }
end
