# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Cascade Delete", type: :model do
  # ==========================================================
  # P2-TE-001: カスケード削除テスト
  # テスター: ミッコ（第2中隊）
  #
  # dependent: :destroy による連鎖削除を検証
  # ==========================================================

  describe "Character deletion cascades" do
    let!(:character) { create(:character, name: "削除対象キャラ") }
    let!(:other_char) { create(:character, name: "相手キャラ") }

    # --- CAS-005: Character 削除時に character_id を持つ relationships が削除されること ---
    context "when character has relationships as source" do
      it "destroys relationships where character is the source" do
        create(:character_relationship, character: character, related_character: other_char)
        expect { character.destroy }.to change(CharacterRelationship, :count).by(-1)
      end
    end

    # --- CAS-006: Character 削除時に related_character_id を持つ relationships が削除されること ---
    context "when character has relationships as target" do
      it "destroys relationships where character is the target" do
        create(:character_relationship, character: other_char, related_character: character)
        expect { character.destroy }.to change(CharacterRelationship, :count).by(-1)
      end
    end

    # --- CAS-007: Character 削除時に character_states が削除されること ---
    context "when character has states" do
      it "destroys associated character_states" do
        create(:character_state, character: character, episode_id: 1)
        create(:character_state, character: character, episode_id: 2)
        expect { character.destroy }.to change(CharacterState, :count).by(-2)
      end
    end

    # --- CAS-008: CharacterRelationship 削除時に relationship_logs が削除されること ---
    context "when relationship has logs" do
      it "destroys associated relationship_logs" do
        rel = create(:character_relationship, character: character, related_character: other_char)
        create(:relationship_log, character_relationship: rel, episode_id: 1)
        create(:relationship_log, character_relationship: rel, episode_id: 2)
        expect { rel.destroy }.to change(RelationshipLog, :count).by(-2)
      end
    end
  end

  describe "Chain cascade: Character → Relationships → Logs" do
    # --- CAS-009 相当: Character 削除で relationship_logs も連鎖削除 ---
    context "when character with relationships that have logs is destroyed" do
      it "destroys relationships and their logs in chain" do
        char_a = create(:character, name: "チェーンA")
        char_b = create(:character, name: "チェーンB")
        rel = create(:character_relationship, character: char_a, related_character: char_b)
        create(:relationship_log, character_relationship: rel, episode_id: 1)
        create(:relationship_log, character_relationship: rel, episode_id: 2)

        expect { char_a.destroy }
          .to change(CharacterRelationship, :count).by(-1)
          .and change(RelationshipLog, :count).by(-2)
      end
    end
  end

  describe "Character with multiple associations" do
    it "destroys all associated records in one operation" do
      char = create(:character, name: "フル削除テスト")
      other1 = create(:character, name: "相手1")
      other2 = create(:character, name: "相手2")

      # relationships (source)
      rel1 = create(:character_relationship, character: char, related_character: other1)
      # relationships (target)
      rel2 = create(:character_relationship, character: other2, related_character: char)
      # states
      create(:character_state, character: char, episode_id: 1)
      create(:character_state, character: char, episode_id: 2)
      # logs on relationship
      create(:relationship_log, character_relationship: rel1, episode_id: 1)

      expect { char.destroy }
        .to change(CharacterRelationship, :count).by(-2)
        .and change(CharacterState, :count).by(-2)
        .and change(RelationshipLog, :count).by(-1)
    end
  end

  describe "Deletion does not affect unrelated records" do
    it "preserves other characters' data when one is destroyed" do
      char_a = create(:character, name: "削除するキャラ")
      char_b = create(:character, name: "残すキャラ")
      char_c = create(:character, name: "残すキャラ2")

      # char_a の関連
      create(:character_relationship, character: char_a, related_character: char_b)
      create(:character_state, character: char_a, episode_id: 1)

      # char_b の独自の関連（char_a と無関係）
      create(:character_relationship, character: char_b, related_character: char_c)
      create(:character_state, character: char_b, episode_id: 1)

      char_a.destroy

      # char_b の関連は残っていること
      expect(CharacterRelationship.where(character_id: char_b.id).count).to eq 1
      expect(CharacterState.where(character_id: char_b.id).count).to eq 1
    end
  end
end
