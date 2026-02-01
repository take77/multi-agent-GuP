# frozen_string_literal: true

FactoryBot.define do
  factory :foreshadowing do
    novel_id { 1 }
    sequence(:title) { |n| "伏線#{n}" }
    description { "重要な伏線の説明" }
    planted_episode_id { 1 }
    resolved_episode_id { nil }
    planned_resolution_episode { nil }
    status { :planted }
    importance { :normal }

    trait :hinted do
      status { :hinted }
    end

    trait :resolved do
      status { :resolved }
      resolved_episode_id { 5 }
    end

    trait :abandoned do
      status { :abandoned }
    end

    trait :minor_importance do
      importance { :minor }
    end

    trait :major_importance do
      importance { :major }
    end

    trait :critical_importance do
      importance { :critical }
    end
  end
end
