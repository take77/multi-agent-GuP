# frozen_string_literal: true

# P2-TE-VAL-001: バリデーション境界値テスト
# テスター: ミッコ（第2中隊）
# 全モデルのバリデーション境界値を網羅的にテスト

require "rails_helper"

RSpec.describe "バリデーション境界値テスト", type: :model do
  # === Character ===
  describe Character do
    describe "name バリデーション" do
      it "空文字は無効" do
        char = build(:character, name: "")
        expect(char).not_to be_valid
      end

      it "nilは無効" do
        char = build(:character, name: nil)
        expect(char).not_to be_valid
      end

      it "1文字は有効" do
        char = build(:character, name: "A")
        expect(char).to be_valid
      end
    end

    describe "novel_id バリデーション" do
      it "nilは無効" do
        char = build(:character, novel_id: nil)
        expect(char).not_to be_valid
      end

      it "0は有効（外部キーの値チェックはDB側）" do
        char = build(:character, novel_id: 0)
        expect(char).to be_valid
      end
    end

    describe "age フィールド" do
      it "nilは有効（任意項目）" do
        char = build(:character, age: nil)
        expect(char).to be_valid
      end

      it "整数値は有効" do
        char = build(:character, age: 25)
        expect(char).to be_valid
      end
    end
  end

  # === CharacterRelationship ===
  describe CharacterRelationship do
    let(:char_a) { create(:character) }
    let(:char_b) { create(:character) }

    describe "intensity バリデーション" do
      it "1は有効（下限）" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, intensity: 1)
        expect(rel).to be_valid
      end

      it "10は有効（上限）" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, intensity: 10)
        expect(rel).to be_valid
      end

      it "0は無効（下限未満）" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, intensity: 0)
        expect(rel).not_to be_valid
      end

      it "11は無効（上限超過）" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, intensity: 11)
        expect(rel).not_to be_valid
      end

      it "nilは有効（任意項目）" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, intensity: nil)
        expect(rel).to be_valid
      end

      it "小数は無効（整数のみ）" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, intensity: 5.5)
        expect(rel).not_to be_valid
      end

      it "5は有効（中間値）" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, intensity: 5)
        expect(rel).to be_valid
      end
    end

    describe "relationship_type バリデーション" do
      it "空文字は無効" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, relationship_type: "")
        expect(rel).not_to be_valid
      end

      it "nilは無効" do
        rel = build(:character_relationship, character: char_a,
                    related_character: char_b, relationship_type: nil)
        expect(rel).not_to be_valid
      end
    end

    describe "uniqueness バリデーション" do
      before do
        create(:character_relationship, character: char_a,
               related_character: char_b)
      end

      it "同じペアは重複不可" do
        dup = build(:character_relationship, character: char_a,
                    related_character: char_b)
        expect(dup).not_to be_valid
      end

      it "逆方向は別レコードとして有効" do
        reverse = build(:character_relationship, character: char_b,
                        related_character: char_a)
        expect(reverse).to be_valid
      end
    end
  end

  # === CharacterState ===
  describe CharacterState do
    let(:char) { create(:character) }

    describe "character_id + episode_id uniqueness" do
      before { create(:character_state, character: char, episode_id: 1) }

      it "同キャラ・同エピソードは重複不可" do
        dup = build(:character_state, character: char, episode_id: 1)
        expect(dup).not_to be_valid
      end

      it "同キャラ・別エピソードは有効" do
        state = build(:character_state, character: char, episode_id: 2)
        expect(state).to be_valid
      end

      it "別キャラ・同エピソードは有効" do
        other_char = create(:character)
        state = build(:character_state, character: other_char, episode_id: 1)
        expect(state).to be_valid
      end
    end

    describe "inventory JSONB" do
      it "空配列は有効" do
        state = build(:character_state, character: char, inventory: [])
        expect(state).to be_valid
      end

      it "配列要素が入った状態は有効" do
        state = build(:character_state, character: char,
                      inventory: [{ name: "剣", quantity: 1 }])
        expect(state).to be_valid
      end
    end
  end

  # === Foreshadowing ===
  describe Foreshadowing do
    describe "status enum" do
      it "plantedは有効" do
        f = build(:foreshadowing, status: :planted)
        expect(f).to be_valid
        expect(f.planted?).to be true
      end

      it "hintedは有効" do
        f = build(:foreshadowing, status: :hinted)
        expect(f).to be_valid
        expect(f.hinted?).to be true
      end

      it "resolvedは有効" do
        f = build(:foreshadowing, status: :resolved)
        expect(f).to be_valid
        expect(f.resolved?).to be true
      end

      it "abandonedは有効" do
        f = build(:foreshadowing, status: :abandoned)
        expect(f).to be_valid
        expect(f.abandoned?).to be true
      end

      it "不正な値はArgumentError" do
        expect { build(:foreshadowing, status: :invalid) }.to raise_error(ArgumentError)
      end
    end

    describe "importance enum" do
      it "minor (0) は有効" do
        f = build(:foreshadowing, importance: :minor)
        expect(f).to be_valid
      end

      it "normal (1) は有効" do
        f = build(:foreshadowing, importance: :normal)
        expect(f).to be_valid
      end

      it "major (2) は有効" do
        f = build(:foreshadowing, importance: :major)
        expect(f).to be_valid
      end

      it "critical (3) は有効" do
        f = build(:foreshadowing, importance: :critical)
        expect(f).to be_valid
      end
    end

    describe "title バリデーション" do
      it "nilは無効" do
        f = build(:foreshadowing, title: nil)
        expect(f).not_to be_valid
      end

      it "空文字は無効" do
        f = build(:foreshadowing, title: "")
        expect(f).not_to be_valid
      end

      it "1文字は有効" do
        f = build(:foreshadowing, title: "X")
        expect(f).to be_valid
      end
    end
  end

  # === WorldSetting ===
  describe WorldSetting do
    describe "category バリデーション" do
      WorldSetting::CATEGORIES.each do |cat|
        it "#{cat} は有効" do
          ws = build(:world_setting, category: cat)
          expect(ws).to be_valid
        end
      end

      it "不正なカテゴリは無効" do
        ws = build(:world_setting, category: "invalid_category")
        expect(ws).not_to be_valid
      end

      it "空文字は無効" do
        ws = build(:world_setting, category: "")
        expect(ws).not_to be_valid
      end

      it "nilは無効" do
        ws = build(:world_setting, category: nil)
        expect(ws).not_to be_valid
      end
    end

    describe "title バリデーション" do
      it "nilは無効" do
        ws = build(:world_setting, title: nil)
        expect(ws).not_to be_valid
      end

      it "空文字は無効" do
        ws = build(:world_setting, title: "")
        expect(ws).not_to be_valid
      end
    end

    describe "details JSONB" do
      it "ハッシュを保存できる" do
        ws = build(:world_setting, details: { key: "value" })
        expect(ws).to be_valid
      end

      it "空ハッシュは有効" do
        ws = build(:world_setting, details: {})
        expect(ws).to be_valid
      end
    end
  end

  # === RelationshipLog ===
  describe RelationshipLog do
    describe "必須フィールド" do
      it "character_relationship_idがnilは無効" do
        log = build(:relationship_log, character_relationship: nil)
        expect(log).not_to be_valid
      end

      it "episode_idがnilは無効" do
        log = build(:relationship_log, episode_id: nil)
        expect(log).not_to be_valid
      end
    end

    describe "オプショナルフィールド" do
      let!(:rel) { create(:character_relationship) }

      it "change_descriptionがnilは有効" do
        log = build(:relationship_log, character_relationship: rel, change_description: nil)
        expect(log).to be_valid
      end

      it "previous_typeがnilは有効" do
        log = build(:relationship_log, character_relationship: rel, previous_type: nil)
        expect(log).to be_valid
      end

      it "intensity値がnilは有効" do
        log = build(:relationship_log, character_relationship: rel, previous_intensity: nil, new_intensity: nil)
        expect(log).to be_valid
      end
    end
  end
end
