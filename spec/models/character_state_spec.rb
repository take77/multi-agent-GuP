# frozen_string_literal: true

require "rails_helper"

RSpec.describe CharacterState, type: :model do
  # ==========================================================
  # P2-TE-001: データ整合性テスト - character_states テーブル
  # テスター: ミッコ（第2中隊）
  # ==========================================================

  describe "associations" do
    it "belongs to character" do
      assoc = described_class.reflect_on_association(:character)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  describe "validations" do
    let(:character) { create(:character) }

    # --- VAL-CS-001: character_id + episode_id の組み合わせがユニークであること ---
    context "when character_id + episode_id combination is unique" do
      it "is valid" do
        cs = build(:character_state, character: character, episode_id: 1)
        expect(cs).to be_valid
      end
    end

    # --- VAL-CS-002: 同一 character_id + episode_id の重複登録がエラーになること ---
    context "when duplicate character_id + episode_id exists" do
      it "is invalid" do
        create(:character_state, character: character, episode_id: 1)
        duplicate = build(:character_state, character: character, episode_id: 1)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:character_id]).to include("has already been taken")
      end
    end

    # --- VAL-CS-003: character_id が nil の場合 ---
    context "when character_id is nil" do
      it "is invalid" do
        cs = build(:character_state, character: nil, character_id: nil)
        expect(cs).not_to be_valid
      end
    end

    # --- VAL-CS-004: episode_id が nil の場合 ---
    context "when episode_id is nil" do
      it "is invalid" do
        cs = build(:character_state, character: character, episode_id: nil)
        expect(cs).not_to be_valid
        expect(cs.errors[:episode_id]).to include("can't be blank")
      end
    end

    # --- VAL-CS-005: inventory に有効なJSONBデータを保存できること ---
    context "when inventory contains valid JSONB data" do
      it "saves array of items" do
        cs = create(:character_state, character: character, episode_id: 1,
                    inventory: [{ name: "剣", quantity: 1 }, { name: "盾", quantity: 1 }])
        cs.reload
        expect(cs.inventory).to be_an(Array)
        expect(cs.inventory.length).to eq 2
      end

      it "saves empty array" do
        cs = create(:character_state, character: character, episode_id: 2, inventory: [])
        cs.reload
        expect(cs.inventory).to eq []
      end
    end

    # --- VAL-CS-006: emotional_state が空でも作成できること（任意フィールド）---
    context "when optional fields are empty" do
      it "is valid without emotional_state" do
        cs = build(:character_state, character: character, emotional_state: nil)
        expect(cs).to be_valid
      end

      it "is valid without physical_state" do
        cs = build(:character_state, character: character, physical_state: nil)
        expect(cs).to be_valid
      end

      it "is valid without location" do
        cs = build(:character_state, character: character, location: nil)
        expect(cs).to be_valid
      end

      it "is valid without knowledge" do
        cs = build(:character_state, character: character, knowledge: nil)
        expect(cs).to be_valid
      end

      it "is valid without notes" do
        cs = build(:character_state, character: character, notes: nil)
        expect(cs).to be_valid
      end
    end

    context "when all attributes are valid" do
      it "creates successfully" do
        cs = build(:character_state, character: character)
        expect(cs).to be_valid
        expect { cs.save! }.not_to raise_error
      end
    end
  end

  describe "uniqueness at different episodes" do
    let(:character) { create(:character) }

    it "allows same character with different episode_ids" do
      create(:character_state, character: character, episode_id: 1)
      cs2 = build(:character_state, character: character, episode_id: 2)
      expect(cs2).to be_valid
    end

    it "allows different characters with same episode_id" do
      char2 = create(:character, name: "別キャラ")
      create(:character_state, character: character, episode_id: 1)
      cs2 = build(:character_state, character: char2, episode_id: 1)
      expect(cs2).to be_valid
    end
  end
end
