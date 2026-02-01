# frozen_string_literal: true

FactoryBot.define do
  factory :character_state do
    association :character
    sequence(:episode_id) { |n| n }
    location { "王都" }
    emotional_state { "平穏" }
    physical_state { "健康" }
    knowledge { "魔法の基礎を習得済み" }
    inventory { [{ name: "魔法の杖", quantity: 1 }] }
    notes { "" }
  end
end
