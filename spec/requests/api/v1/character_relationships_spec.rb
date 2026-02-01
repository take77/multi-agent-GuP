# frozen_string_literal: true

# P2-TE-REQ-004: CharacterRelationships API Request Spec
# テスター: ミッコ（第2中隊）

require "rails_helper"

RSpec.describe "Api::V1::CharacterRelationships", type: :request do
  let(:novel_id) { 1 }
  let(:base_path) { "/api/v1/novels/#{novel_id}/character_relationships" }
  let!(:char_a) { create(:character, novel_id: novel_id, name: "キャラA") }
  let!(:char_b) { create(:character, novel_id: novel_id, name: "キャラB") }
  let!(:char_c) { create(:character, novel_id: novel_id, name: "キャラC") }

  describe "GET /api/v1/novels/:novel_id/character_relationships" do
    before do
      create(:character_relationship, novel_id: novel_id,
             character: char_a, related_character: char_b, relationship_type: "友人")
      create(:character_relationship, novel_id: novel_id,
             character: char_b, related_character: char_c, relationship_type: "ライバル")
      create(:character_relationship, novel_id: 999,
             character: create(:character, novel_id: 999),
             related_character: create(:character, novel_id: 999))
    end

    it "指定小説の関係性一覧を返す" do
      get base_path
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"].length).to eq 2
    end

    it "キャラクター名が含まれる" do
      get base_path
      body = JSON.parse(response.body)
      first = body["data"].first
      expect(first["character"]).to include("id", "name")
      expect(first["related_character"]).to include("id", "name")
    end

    it "ページネーションが機能する" do
      get base_path, params: { per_page: 1 }
      body = JSON.parse(response.body)
      expect(body["data"].length).to eq 1
      expect(body["meta"]["total"]).to eq 2
    end
  end

  describe "GET /api/v1/novels/:novel_id/character_relationships/:id" do
    let!(:rel) do
      create(:character_relationship, novel_id: novel_id,
             character: char_a, related_character: char_b)
    end

    it "関係性の詳細を返す" do
      get "#{base_path}/#{rel.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["id"]).to eq rel.id
      expect(body["data"]["character"]["name"]).to eq "キャラA"
      expect(body["data"]["related_character"]["name"]).to eq "キャラB"
    end

    it "存在しないIDは404" do
      get "#{base_path}/99999"
      expect(response).to have_http_status(:not_found)
    end

    it "別小説の関係性は404" do
      other_rel = create(:character_relationship, novel_id: 999,
                         character: create(:character, novel_id: 999),
                         related_character: create(:character, novel_id: 999))
      get "#{base_path}/#{other_rel.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/novels/:novel_id/character_relationships" do
    context "正常なパラメータ" do
      it "関係性を作成できる" do
        expect {
          post base_path, params: {
            character_relationship: {
              character_id: char_a.id,
              related_character_id: char_b.id,
              relationship_type: "師弟",
              description: "魔法の師匠と弟子",
              intensity: 7
            }
          }
        }.to change(CharacterRelationship, :count).by(1)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["data"]["relationship_type"]).to eq "師弟"
        expect(body["data"]["intensity"]).to eq 7
      end
    end

    context "存在しないキャラクターID" do
      it "404を返す" do
        post base_path, params: {
          character_relationship: {
            character_id: 99999,
            related_character_id: char_b.id,
            relationship_type: "友人"
          }
        }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "別小説のキャラクターID" do
      let!(:other_char) { create(:character, novel_id: 999) }

      it "404を返す" do
        post base_path, params: {
          character_relationship: {
            character_id: char_a.id,
            related_character_id: other_char.id,
            relationship_type: "友人"
          }
        }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "重複する関係性" do
      before do
        create(:character_relationship, novel_id: novel_id,
               character: char_a, related_character: char_b)
      end

      it "バリデーションエラーを返す" do
        post base_path, params: {
          character_relationship: {
            character_id: char_a.id,
            related_character_id: char_b.id,
            relationship_type: "ライバル"
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "relationship_typeなし" do
      it "バリデーションエラーを返す" do
        post base_path, params: {
          character_relationship: {
            character_id: char_a.id,
            related_character_id: char_b.id
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /api/v1/novels/:novel_id/character_relationships/:id" do
    let!(:rel) do
      create(:character_relationship, novel_id: novel_id,
             character: char_a, related_character: char_b,
             relationship_type: "知人", intensity: 3)
    end

    it "更新できる" do
      put "#{base_path}/#{rel.id}", params: {
        character_relationship: { relationship_type: "親友", intensity: 9 }
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["relationship_type"]).to eq "親友"
      expect(body["data"]["intensity"]).to eq 9
    end

    it "存在しないIDは404" do
      put "#{base_path}/99999", params: {
        character_relationship: { relationship_type: "test" }
      }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/novels/:novel_id/character_relationships/:id" do
    let!(:rel) do
      create(:character_relationship, novel_id: novel_id,
             character: char_a, related_character: char_b)
    end

    it "削除できる" do
      expect {
        delete "#{base_path}/#{rel.id}"
      }.to change(CharacterRelationship, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "存在しないIDは404" do
      delete "#{base_path}/99999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
