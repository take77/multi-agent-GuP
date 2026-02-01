# frozen_string_literal: true

require "rails_helper"

RSpec.describe RelationshipLog, type: :model do
  # ==========================================================
  # P2-TE-001: データ整合性テスト - relationship_logs テーブル
  # テスター: ミッコ（第2中隊）
  # ==========================================================

  describe "associations" do
    it "belongs to character_relationship" do
      assoc = described_class.reflect_on_association(:character_relationship)
      expect(assoc.macro).to eq :belongs_to
    end
  end

  describe "validations" do
    let(:relationship) { create(:character_relationship) }

    # --- VAL-RL-001: character_relationship_id が必須であること ---
    context "when character_relationship_id is nil" do
      it "is invalid" do
        log = build(:relationship_log, character_relationship: nil, character_relationship_id: nil)
        expect(log).not_to be_valid
      end
    end

    # --- VAL-RL-002: episode_id が必須であること ---
    context "when episode_id is nil" do
      it "is invalid" do
        log = build(:relationship_log, character_relationship: relationship, episode_id: nil)
        expect(log).not_to be_valid
        expect(log.errors[:episode_id]).to include("can't be blank")
      end
    end

    # --- VAL-RL-004: previous_type と new_type が記録されること ---
    context "when type change is recorded" do
      it "stores previous_type and new_type" do
        log = create(:relationship_log,
                     character_relationship: relationship,
                     previous_type: "知人",
                     new_type: "友人")
        log.reload
        expect(log.previous_type).to eq "知人"
        expect(log.new_type).to eq "友人"
      end
    end

    # --- VAL-RL-005: previous_intensity と new_intensity が記録されること ---
    context "when intensity change is recorded" do
      it "stores previous_intensity and new_intensity" do
        log = create(:relationship_log,
                     character_relationship: relationship,
                     previous_intensity: 3,
                     new_intensity: 7)
        log.reload
        expect(log.previous_intensity).to eq 3
        expect(log.new_intensity).to eq 7
      end
    end

    # --- VAL-RL-003: change_description の記録確認 ---
    context "when change_description is provided" do
      it "stores the description" do
        log = create(:relationship_log,
                     character_relationship: relationship,
                     change_description: "戦いを通じて絆が深まった")
        log.reload
        expect(log.change_description).to eq "戦いを通じて絆が深まった"
      end
    end

    context "when change_description is nil" do
      it "is valid (optional field)" do
        log = build(:relationship_log, character_relationship: relationship, change_description: nil)
        expect(log).to be_valid
      end
    end

    context "when all attributes are valid" do
      it "creates successfully" do
        log = build(:relationship_log, character_relationship: relationship)
        expect(log).to be_valid
        expect { log.save! }.not_to raise_error
      end
    end
  end

  describe "multiple logs for same relationship" do
    let(:relationship) { create(:character_relationship) }

    it "allows multiple logs for the same relationship" do
      create(:relationship_log, character_relationship: relationship, episode_id: 1,
             previous_type: "知人", new_type: "友人")
      log2 = build(:relationship_log, character_relationship: relationship, episode_id: 2,
                   previous_type: "友人", new_type: "親友")
      expect(log2).to be_valid
    end
  end
end
