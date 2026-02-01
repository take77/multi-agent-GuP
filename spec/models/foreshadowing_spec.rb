# frozen_string_literal: true

require "rails_helper"

RSpec.describe Foreshadowing, type: :model do
  # ==========================================================
  # P2-TE-001: データ整合性テスト - foreshadowings テーブル
  # テスター: ミッコ（第2中隊）
  # ==========================================================

  describe "enums" do
    it "defines status enum with correct values" do
      expect(described_class.statuses).to eq(
        "planted" => 0, "hinted" => 1, "resolved" => 2, "abandoned" => 3
      )
    end

    it "defines importance enum with prefix" do
      expect(described_class.importances).to eq(
        "minor" => 0, "normal" => 1, "major" => 2, "critical" => 3
      )
    end
  end

  describe "validations" do
    # --- VAL-FS-001〜004: status が有効な enum 値の場合 ---
    %w[planted hinted resolved abandoned].each do |valid_status|
      context "when status is '#{valid_status}'" do
        it "is valid" do
          fs = build(:foreshadowing, status: valid_status)
          expect(fs).to be_valid
        end
      end
    end

    # --- VAL-FS-005: status が無効な値の場合 ---
    context "when status is an invalid value" do
      it "raises ArgumentError" do
        expect {
          build(:foreshadowing, status: :invalid_status)
        }.to raise_error(ArgumentError)
      end
    end

    # --- VAL-FS-006〜009: importance が有効な enum 値の場合 ---
    %w[minor normal major critical].each do |valid_importance|
      context "when importance is '#{valid_importance}'" do
        it "is valid" do
          fs = build(:foreshadowing, importance: valid_importance)
          expect(fs).to be_valid
        end
      end
    end

    # --- VAL-FS-010: importance が無効な値の場合 ---
    context "when importance is an invalid value" do
      it "raises ArgumentError" do
        expect {
          build(:foreshadowing, importance: :invalid_importance)
        }.to raise_error(ArgumentError)
      end
    end

    # --- VAL-FS-011: title が空の場合 ---
    context "when title is empty" do
      it "is invalid" do
        fs = build(:foreshadowing, title: "")
        expect(fs).not_to be_valid
        expect(fs.errors[:title]).to include("can't be blank")
      end
    end

    context "when title is nil" do
      it "is invalid" do
        fs = build(:foreshadowing, title: nil)
        expect(fs).not_to be_valid
        expect(fs.errors[:title]).to include("can't be blank")
      end
    end

    # --- VAL-FS-012: novel_id が nil の場合 ---
    context "when novel_id is nil" do
      it "is invalid" do
        fs = build(:foreshadowing, novel_id: nil)
        expect(fs).not_to be_valid
        expect(fs.errors[:novel_id]).to include("can't be blank")
      end
    end

    # --- VAL-FS-014: resolved_episode_id が nullable であること ---
    context "when resolved_episode_id is nil (unresolved)" do
      it "is valid" do
        fs = build(:foreshadowing, resolved_episode_id: nil)
        expect(fs).to be_valid
      end
    end

    context "when resolved_episode_id is present" do
      it "is valid" do
        fs = build(:foreshadowing, resolved_episode_id: 5)
        expect(fs).to be_valid
      end
    end

    context "when all attributes are valid" do
      it "creates successfully" do
        fs = build(:foreshadowing)
        expect(fs).to be_valid
        expect { fs.save! }.not_to raise_error
      end
    end
  end

  describe "enum scopes" do
    before do
      create(:foreshadowing, status: :planted, importance: :normal)
      create(:foreshadowing, status: :hinted, importance: :major)
      create(:foreshadowing, status: :resolved, importance: :critical)
      create(:foreshadowing, status: :abandoned, importance: :minor)
    end

    it "filters by planted status" do
      expect(described_class.planted.count).to eq 1
    end

    it "filters by hinted status" do
      expect(described_class.hinted.count).to eq 1
    end

    it "filters by resolved status" do
      expect(described_class.resolved.count).to eq 1
    end

    it "filters by abandoned status" do
      expect(described_class.abandoned.count).to eq 1
    end
  end
end
