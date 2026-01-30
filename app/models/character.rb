# frozen_string_literal: true

class Character < ApplicationRecord
  # === Associations ===
  # novels テーブルは第1中隊担当。揃い次第有効化。
  # belongs_to :novel
  has_many :character_relationships, dependent: :destroy
  has_many :inverse_character_relationships, class_name: "CharacterRelationship",
           foreign_key: :related_character_id, dependent: :destroy
  has_many :character_states, dependent: :destroy

  # === Validations ===
  validates :novel_id, presence: true
  validates :name, presence: true
end
