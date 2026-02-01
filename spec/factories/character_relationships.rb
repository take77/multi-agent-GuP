# frozen_string_literal: true

FactoryBot.define do
  factory :character_relationship do
    novel_id { 1 }
    association :character
    association :related_character, factory: :character
    relationship_type { "友人" }
    description { "幼馴染で親友" }
    intensity { 5 }
  end
end
