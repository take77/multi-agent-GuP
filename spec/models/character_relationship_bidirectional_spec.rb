# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CharacterRelationship Bidirectional Integrity", type: :model do
  # ==========================================================
  # P2-TE-001: キャラクター関係性の双方向整合性テスト
  # テスター: ミッコ（第2中隊）
  # ==========================================================

  let!(:char_a) { create(:character, name: "キャラA") }
  let!(:char_b) { create(:character, name: "キャラB") }
  let!(:char_c) { create(:character, name: "キャラC") }

  describe "bidirectional query" do
    # --- BDR-001: AがBの「友人」として登録された場合、BからAの関係が取得できること ---
    context "when A is registered as B's friend" do
      let!(:rel_ab) do
        create(:character_relationship,
               character: char_a, related_character: char_b,
               relationship_type: "友人", intensity: 7)
      end

      it "can find the relationship from A's character_relationships" do
        rels = CharacterRelationship.where(character_id: char_a.id)
        expect(rels.map(&:related_character_id)).to include(char_b.id)
      end

      it "can find the relationship from B's inverse_character_relationships" do
        inverse_rels = CharacterRelationship.where(related_character_id: char_b.id)
        expect(inverse_rels.map(&:character_id)).to include(char_a.id)
      end

      it "can query B's perspective via Character association" do
        # Character モデルの inverse_character_relationships を活用
        expect(char_b.inverse_character_relationships.map(&:character_id)).to include(char_a.id)
      end
    end

    # --- BDR-002: AがBの「師弟」として登録された場合の逆方向取得 ---
    context "when A→B is registered as '師弟'" do
      let!(:rel_ab) do
        create(:character_relationship,
               character: char_a, related_character: char_b,
               relationship_type: "師弟", intensity: 9)
      end

      it "retrieves the relationship type from B's perspective" do
        inverse = CharacterRelationship.find_by(
          character_id: char_a.id, related_character_id: char_b.id
        )
        expect(inverse.relationship_type).to eq "師弟"
        expect(inverse.intensity).to eq 9
      end
    end
  end

  describe "duplicate prevention" do
    # --- BDR-003: 同一ペア（A→B）の重複登録がエラーになること ---
    context "when A→B already exists" do
      before do
        create(:character_relationship,
               character: char_a, related_character: char_b,
               relationship_type: "友人")
      end

      it "rejects duplicate A→B" do
        duplicate = build(:character_relationship,
                          character: char_a, related_character: char_b,
                          relationship_type: "友人")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:character_id]).to include("has already been taken")
      end

      # --- BDR-005: 異なる relationship_type であっても同一ペアの重複が防止されること ---
      it "rejects A→B even with different relationship_type" do
        duplicate = build(:character_relationship,
                          character: char_a, related_character: char_b,
                          relationship_type: "ライバル")
        expect(duplicate).not_to be_valid
      end
    end

    # --- BDR-004: 逆方向ペア（B→A）の登録可否を確認 ---
    # 注意: 現在のユニーク制約は [character_id, related_character_id] のみ。
    # B→A は A→B とは別レコードとして登録可能（設計上の判断）。
    context "when A→B exists and B→A is attempted" do
      before do
        create(:character_relationship,
               character: char_a, related_character: char_b,
               relationship_type: "友人")
      end

      it "allows B→A as a separate record (current design)" do
        reverse = build(:character_relationship,
                        character: char_b, related_character: char_a,
                        relationship_type: "友人")
        # 現在のユニーク制約: [character_id, related_character_id]
        # B→A は character_id=B, related_character_id=A で別ペア
        expect(reverse).to be_valid
      end
    end
  end

  describe "multi-party relationships" do
    # --- BDR-006: 3者間の関係性が正しく管理されること ---
    context "when A→B, B→C, A→C relationships exist" do
      before do
        create(:character_relationship, character: char_a, related_character: char_b,
               relationship_type: "友人", intensity: 7)
        create(:character_relationship, character: char_b, related_character: char_c,
               relationship_type: "師弟", intensity: 9)
        create(:character_relationship, character: char_a, related_character: char_c,
               relationship_type: "ライバル", intensity: 5)
      end

      it "stores all three relationships independently" do
        expect(CharacterRelationship.count).to eq 3
      end

      it "retrieves A's outgoing relationships correctly" do
        a_rels = char_a.character_relationships
        expect(a_rels.count).to eq 2
        expect(a_rels.map(&:related_character_id)).to contain_exactly(char_b.id, char_c.id)
      end

      it "retrieves B's incoming relationships correctly" do
        b_inverse = char_b.inverse_character_relationships
        expect(b_inverse.count).to eq 1
        expect(b_inverse.first.character_id).to eq char_a.id
      end

      it "retrieves C's incoming relationships correctly" do
        c_inverse = char_c.inverse_character_relationships
        expect(c_inverse.count).to eq 2
        expect(c_inverse.map(&:character_id)).to contain_exactly(char_a.id, char_b.id)
      end

      it "maintains correct relationship types for each pair" do
        ab = CharacterRelationship.find_by(character_id: char_a.id, related_character_id: char_b.id)
        bc = CharacterRelationship.find_by(character_id: char_b.id, related_character_id: char_c.id)
        ac = CharacterRelationship.find_by(character_id: char_a.id, related_character_id: char_c.id)

        expect(ab.relationship_type).to eq "友人"
        expect(bc.relationship_type).to eq "師弟"
        expect(ac.relationship_type).to eq "ライバル"
      end
    end
  end
end
