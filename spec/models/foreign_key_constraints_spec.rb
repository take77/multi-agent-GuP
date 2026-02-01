# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Foreign Key Constraints", type: :model do
  # ==========================================================
  # P2-TE-001: 外部キー制約テスト
  # テスター: ミッコ（第2中隊）
  #
  # 注意: novel_id, episode_id は第1中隊担当のため、
  # DB レベルの外部キー制約なし（bigint カラムのみ）。
  # belongs_to が設定されている関連のみ FK テスト可能。
  # ==========================================================

  describe "CharacterRelationship FK constraints" do
    # --- FK-003: 存在しない character_id ---
    context "when character_id references a non-existent character" do
      it "raises ActiveRecord::InvalidForeignKey or RecordInvalid" do
        char_b = create(:character, name: "キャラB")
        rel = CharacterRelationship.new(
          novel_id: 1,
          character_id: 999_999,
          related_character_id: char_b.id,
          relationship_type: "友人",
          intensity: 5
        )
        expect { rel.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    # --- FK-004: 存在しない related_character_id ---
    context "when related_character_id references a non-existent character" do
      it "raises ActiveRecord::StatementInvalid" do
        char_a = create(:character, name: "キャラA")
        rel = CharacterRelationship.new(
          novel_id: 1,
          character_id: char_a.id,
          related_character_id: 999_999,
          relationship_type: "友人",
          intensity: 5
        )
        expect { rel.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe "CharacterState FK constraints" do
    # --- FK-007: 存在しない character_id ---
    context "when character_id references a non-existent character" do
      it "raises ActiveRecord::StatementInvalid" do
        cs = CharacterState.new(
          character_id: 999_999,
          episode_id: 1,
          location: "王都"
        )
        expect { cs.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe "RelationshipLog FK constraints" do
    # --- FK-009: 存在しない character_relationship_id ---
    context "when character_relationship_id references a non-existent relationship" do
      it "raises ActiveRecord::StatementInvalid" do
        log = RelationshipLog.new(
          character_relationship_id: 999_999,
          episode_id: 1,
          change_description: "テスト"
        )
        expect { log.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe "Model-level validation for novel_id / episode_id (no DB FK)" do
    # novel_id, episode_id は DB FK なし。モデルバリデーションのみ。

    # --- FK-001: novel_id が nil → Character バリデーションエラー ---
    it "Character rejects nil novel_id" do
      char = build(:character, novel_id: nil)
      expect(char).not_to be_valid
      expect(char.errors[:novel_id]).to be_present
    end

    # --- FK-002: novel_id が nil → WorldSetting バリデーションエラー ---
    it "WorldSetting rejects nil novel_id" do
      ws = build(:world_setting, novel_id: nil)
      expect(ws).not_to be_valid
      expect(ws.errors[:novel_id]).to be_present
    end

    # --- FK-005: novel_id が nil → Foreshadowing バリデーションエラー ---
    it "Foreshadowing rejects nil novel_id" do
      fs = build(:foreshadowing, novel_id: nil)
      expect(fs).not_to be_valid
      expect(fs.errors[:novel_id]).to be_present
    end

    # --- FK-008: episode_id が nil → CharacterState バリデーションエラー ---
    it "CharacterState rejects nil episode_id" do
      cs = build(:character_state, episode_id: nil)
      expect(cs).not_to be_valid
      expect(cs.errors[:episode_id]).to be_present
    end

    # --- FK-010: episode_id が nil → RelationshipLog バリデーションエラー ---
    it "RelationshipLog rejects nil episode_id" do
      rel = create(:character_relationship)
      log = build(:relationship_log, character_relationship: rel, episode_id: nil)
      expect(log).not_to be_valid
      expect(log.errors[:episode_id]).to be_present
    end
  end
end
