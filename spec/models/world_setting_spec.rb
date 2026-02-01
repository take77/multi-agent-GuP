# frozen_string_literal: true

require "rails_helper"

RSpec.describe WorldSetting, type: :model do
  # ==========================================================
  # P2-TE-001: データ整合性テスト - world_settings テーブル
  # テスター: ミッコ（第2中隊）
  # ==========================================================

  describe "validations" do
    # --- VAL-WS-001〜005: category が有効な値の場合、作成に成功すること ---
    %w[geography magic culture history politics].each do |valid_category|
      context "when category is '#{valid_category}'" do
        it "is valid" do
          ws = build(:world_setting, category: valid_category)
          expect(ws).to be_valid
        end
      end
    end

    # --- VAL-WS-006: category が無効な値の場合、バリデーションエラーになること ---
    context "when category is an invalid value" do
      it "is invalid" do
        ws = build(:world_setting, category: "invalid_category")
        expect(ws).not_to be_valid
        expect(ws.errors[:category]).to include("is not included in the list")
      end
    end

    # --- VAL-WS-007: category が空の場合、バリデーションエラーになること ---
    context "when category is empty" do
      it "is invalid" do
        ws = build(:world_setting, category: "")
        expect(ws).not_to be_valid
        expect(ws.errors[:category]).to be_present
      end
    end

    # --- VAL-WS-008: novel_id が nil の場合、バリデーションエラーになること ---
    context "when novel_id is nil" do
      it "is invalid" do
        ws = build(:world_setting, novel_id: nil)
        expect(ws).not_to be_valid
        expect(ws.errors[:novel_id]).to include("can't be blank")
      end
    end

    # --- VAL-WS-009: title が空の場合、バリデーションエラーになること ---
    context "when title is empty" do
      it "is invalid" do
        ws = build(:world_setting, title: "")
        expect(ws).not_to be_valid
        expect(ws.errors[:title]).to include("can't be blank")
      end
    end

    context "when title is nil" do
      it "is invalid" do
        ws = build(:world_setting, title: nil)
        expect(ws).not_to be_valid
        expect(ws.errors[:title]).to include("can't be blank")
      end
    end

    # --- VAL-WS-010: details に有効なJSONBデータを保存できること ---
    context "when details contains valid JSONB data" do
      it "saves nested hash data" do
        ws = create(:world_setting, details: { terrain: "山岳", climate: "温帯", population: 10000 })
        ws.reload
        expect(ws.details).to eq({ "terrain" => "山岳", "climate" => "温帯", "population" => 10000 })
      end

      it "saves array data" do
        ws = create(:world_setting, details: [{ name: "ルール1" }, { name: "ルール2" }])
        ws.reload
        expect(ws.details).to be_an(Array)
        expect(ws.details.length).to eq 2
      end

      it "saves nil details" do
        ws = build(:world_setting, details: nil)
        expect(ws).to be_valid
      end
    end

    context "when all attributes are valid" do
      it "creates successfully" do
        ws = build(:world_setting)
        expect(ws).to be_valid
        expect { ws.save! }.not_to raise_error
      end
    end
  end

  describe "constants" do
    it "defines CATEGORIES with 5 valid values" do
      expect(WorldSetting::CATEGORIES).to eq %w[geography magic culture history politics]
    end
  end
end
