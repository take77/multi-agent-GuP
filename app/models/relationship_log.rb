# frozen_string_literal: true

class RelationshipLog < ApplicationRecord
  # === Associations ===
  belongs_to :character_relationship
  # belongs_to :episode  # 第1中隊担当。揃い次第有効化。

  # === Validations ===
  validates :character_relationship_id, presence: true
  validates :episode_id, presence: true
end
