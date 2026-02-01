# frozen_string_literal: true

FactoryBot.define do
  factory :world_setting do
    novel_id { 1 }
    category { "geography" }
    sequence(:title) { |n| "設定項目#{n}" }
    description { "世界観の詳細説明" }
    details { { terrain: "山岳", climate: "温帯" } }
  end
end
