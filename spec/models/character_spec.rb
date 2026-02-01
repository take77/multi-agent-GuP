# frozen_string_literal: true

require "rails_helper"

RSpec.describe Character, type: :model do
  # ==========================================================
  # P2-TE-001: データ整合性テスト - characters テーブル
  # テスター: ミッコ（第2中隊）
  # ==========================================================

  describe "associations" do
    it "has many character_relationships" do
      assoc = described_class.reflect_on_association(:character_relationships)
      expect(assoc.macro).to eq :has_many
    end

    it "has many inverse_character_relationships" do
      assoc = described_class.reflect_on_association(:inverse_character_relationships)
      expect(assoc.macro).to eq :has_many
      expect(assoc.options[:foreign_key]).to eq :related_character_id
    end

    it "has many character_states" do
      assoc = described_class.reflect_on_association(:character_states)
      expect(assoc.macro).to eq :has_many
    end
  end

  describe "validations" do
    # --- VAL-CHR-001: name が存在する場合、作成に成功すること ---
    context "when name is present" do
      it "is valid" do
        character = build(:character, name: "太郎")
        expect(character).to be_valid
      end
    end

    # --- VAL-CHR-002: name が空の場合、バリデーションエラーになること ---
    context "when name is empty string" do
      it "is invalid" do
        character = build(:character, name: "")
        expect(character).not_to be_valid
        expect(character.errors[:name]).to include("can't be blank")
      end
    end

    # --- VAL-CHR-003: name が nil の場合、バリデーションエラーになること ---
    context "when name is nil" do
      it "is invalid" do
        character = build(:character, name: nil)
        expect(character).not_to be_valid
        expect(character.errors[:name]).to include("can't be blank")
      end
    end

    # --- VAL-CHR-004: novel_id が存在する場合、作成に成功すること ---
    context "when novel_id is present" do
      it "is valid" do
        character = build(:character, novel_id: 1)
        expect(character).to be_valid
      end
    end

    # --- VAL-CHR-005: novel_id が nil の場合、バリデーションエラーになること ---
    context "when novel_id is nil" do
      it "is invalid" do
        character = build(:character, novel_id: nil)
        expect(character).not_to be_valid
        expect(character.errors[:novel_id]).to include("can't be blank")
      end
    end

    # --- VAL-CHR-006: role に有効な値を設定した場合、作成に成功すること ---
    context "when role has a valid value" do
      it "is valid with role '主人公'" do
        character = build(:character, role: "主人公")
        expect(character).to be_valid
      end

      it "is valid with role 'ヒロイン'" do
        character = build(:character, role: "ヒロイン")
        expect(character).to be_valid
      end
    end

    # --- VAL-CHR-007: age に負の値を設定した場合の挙動を確認 ---
    context "when age is negative" do
      it "does not raise an error at model level (no validation on age)" do
        character = build(:character, age: -1)
        # age にバリデーションが未設定のため、モデルレベルでは通る
        expect(character).to be_valid
      end
    end

    context "when all attributes are valid" do
      it "creates successfully" do
        character = build(:character)
        expect(character).to be_valid
        expect { character.save! }.not_to raise_error
      end
    end
  end

  describe "dependent destroy" do
    let!(:character) { create(:character) }

    it "destroys associated character_relationships on destroy" do
      related = create(:character)
      create(:character_relationship, character: character, related_character: related)
      expect { character.destroy }.to change(CharacterRelationship, :count).by(-1)
    end

    it "destroys associated inverse_character_relationships on destroy" do
      other = create(:character)
      create(:character_relationship, character: other, related_character: character)
      expect { character.destroy }.to change(CharacterRelationship, :count).by(-1)
    end

    it "destroys associated character_states on destroy" do
      create(:character_state, character: character)
      expect { character.destroy }.to change(CharacterState, :count).by(-1)
    end
  end
end
