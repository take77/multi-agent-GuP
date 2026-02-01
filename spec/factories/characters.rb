# frozen_string_literal: true

FactoryBot.define do
  factory :character do
    novel_id { 1 }
    sequence(:name) { |n| "キャラクター#{n}" }
    age { 18 }
    appearance { "黒髪ロング" }
    abilities { "魔法" }
    personality { "真面目" }
    speech_style { "丁寧語" }
    background { "王国出身" }
    role { "主人公" }
  end
end
