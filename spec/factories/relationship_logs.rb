# frozen_string_literal: true

FactoryBot.define do
  factory :relationship_log do
    association :character_relationship
    sequence(:episode_id) { |n| n }
    change_description { "関係性が変化した" }
    previous_type { "知人" }
    new_type { "友人" }
    previous_intensity { 3 }
    new_intensity { 6 }
  end
end
