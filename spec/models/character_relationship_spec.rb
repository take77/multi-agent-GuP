# frozen_string_literal: true

require "rails_helper"

RSpec.describe CharacterRelationship, type: :model do
  # ==========================================================
  # P2-TE-001: データ整合性テスト - character_relationships テーブル
  # テスター: ミッコ（第2中隊）
  # ==========================================================

  describe "associations" do
    it "belongs to character" do
      assoc = described_class.reflect_on_association(:character)
      expect(assoc.macro).to eq :belongs_to
    end

    it "belongs to related_character" do
      assoc = described_class.reflect_on_association(:related_character)
      expect(assoc.macro).to eq :belongs_to
      expect(assoc.options[:class_name]).to eq "Character"
    end

    it "has many relationship_logs" do
      assoc = described_class.reflect_on_association(:relationship_logs)
      expect(assoc.macro).to eq :has_many
    end
  end

  describe "validations" do
    let(:char_a) { create(:character, name: "キャラA") }
    let(:char_b) { create(:character, name: "キャラB") }

    # --- VAL-CR-001: intensity が 1 の場合、作成に成功すること（下限境界値）---
    context "when intensity is 1 (lower boundary)" do
      it "is valid" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, intensity: 1)
        expect(rel).to be_valid
      end
    end

    # --- VAL-CR-002: intensity が 10 の場合、作成に成功すること（上限境界値）---
    context "when intensity is 10 (upper boundary)" do
      it "is valid" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, intensity: 10)
        expect(rel).to be_valid
      end
    end

    # --- VAL-CR-003: intensity が 5 の場合、作成に成功すること（中間値）---
    context "when intensity is 5 (middle value)" do
      it "is valid" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, intensity: 5)
        expect(rel).to be_valid
      end
    end

    # --- VAL-CR-004: intensity が 0 の場合、バリデーションエラーになること ---
    context "when intensity is 0 (below lower boundary)" do
      it "is invalid" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, intensity: 0)
        expect(rel).not_to be_valid
        expect(rel.errors[:intensity]).to be_present
      end
    end

    # --- VAL-CR-005: intensity が 11 の場合、バリデーションエラーになること ---
    context "when intensity is 11 (above upper boundary)" do
      it "is invalid" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, intensity: 11)
        expect(rel).not_to be_valid
        expect(rel.errors[:intensity]).to be_present
      end
    end

    # --- VAL-CR-006: intensity が nil の場合の挙動（allow_nil: true）---
    context "when intensity is nil" do
      it "is valid (allow_nil: true)" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, intensity: nil)
        expect(rel).to be_valid
      end
    end

    # --- VAL-CR-007: intensity が小数の場合の挙動（only_integer: true）---
    context "when intensity is a decimal" do
      it "is invalid" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, intensity: 5.5)
        expect(rel).not_to be_valid
        expect(rel.errors[:intensity]).to include("must be an integer")
      end
    end

    # --- VAL-CR-008: character_id と related_character_id が同一の場合（自己参照防止）---
    context "when character_id equals related_character_id" do
      it "is invalid (self-reference prevention)" do
        rel = build(:character_relationship, character: char_a, related_character: char_a)
        expect(rel).not_to be_valid
        expect(rel.errors[:related_character_id]).to include("自分自身との関係は設定できません")
      end
    end

    # --- VAL-CR-009: relationship_type が空の場合 ---
    context "when relationship_type is empty" do
      it "is invalid" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, relationship_type: "")
        expect(rel).not_to be_valid
        expect(rel.errors[:relationship_type]).to include("can't be blank")
      end
    end

    # --- VAL-CR-010: novel_id が nil の場合 ---
    context "when novel_id is nil" do
      it "is invalid" do
        rel = build(:character_relationship, character: char_a, related_character: char_b, novel_id: nil)
        expect(rel).not_to be_valid
        expect(rel.errors[:novel_id]).to include("can't be blank")
      end
    end

    # --- uniqueness: character_id + related_character_id ---
    context "when duplicate pair exists" do
      it "is invalid" do
        create(:character_relationship, character: char_a, related_character: char_b)
        duplicate = build(:character_relationship, character: char_a, related_character: char_b)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:character_id]).to include("has already been taken")
      end
    end
  end

  describe "dependent destroy" do
    it "destroys associated relationship_logs on destroy" do
      rel = create(:character_relationship)
      create(:relationship_log, character_relationship: rel)
      expect { rel.destroy }.to change(RelationshipLog, :count).by(-1)
    end
  end
end
