# frozen_string_literal: true

# P2-TE-REQ-006: RelationshipLogs API Request Spec
# テスター: ミッコ（第2中隊）
# Read-onlyエンドポイント（index, show のみ）

require "rails_helper"

RSpec.describe "Api::V1::RelationshipLogs", type: :request do
  let(:novel_id) { 1 }
  let(:base_path) { "/api/v1/novels/#{novel_id}/relationship_logs" }
  let!(:char_a) { create(:character, novel_id: novel_id) }
  let!(:char_b) { create(:character, novel_id: novel_id) }
  let!(:relationship) do
    create(:character_relationship, novel_id: novel_id,
           character: char_a, related_character: char_b)
  end

  describe "GET /api/v1/novels/:novel_id/relationship_logs" do
    before do
      create(:relationship_log, character_relationship: relationship, episode_id: 1,
             previous_type: "知人", new_type: "友人")
      create(:relationship_log, character_relationship: relationship, episode_id: 3,
             previous_type: "友人", new_type: "親友")
    end

    it "関係性変化履歴一覧を返す" do
      get base_path
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["success"]).to be true
      expect(body["data"].length).to eq 2
    end

    it "キャラクター情報がネストされている" do
      get base_path
      body = JSON.parse(response.body)
      first = body["data"].first
      expect(first["character_relationship"]).to be_present
      expect(first["character_relationship"]["character"]).to include("id", "name")
      expect(first["character_relationship"]["related_character"]).to include("id", "name")
    end

    context "episode_idでフィルタリング" do
      it "特定エピソードのログのみ返す" do
        get base_path, params: { episode_id: 1 }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 1
        expect(body["data"].first["episode_id"]).to eq 1
      end
    end

    context "別小説のログ" do
      before do
        other_char = create(:character, novel_id: 999)
        other_rel = create(:character_relationship, novel_id: 999,
                           character: other_char,
                           related_character: create(:character, novel_id: 999))
        create(:relationship_log, character_relationship: other_rel, episode_id: 1)
      end

      it "他の小説のログは含まれない" do
        get base_path
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 2
      end
    end

    context "ページネーション" do
      before do
        8.times { |i| create(:relationship_log, character_relationship: relationship, episode_id: i + 10) }
      end

      it "ページネーションが機能する" do
        get base_path, params: { per_page: 5 }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 5
        expect(body["meta"]["total"]).to eq 10 # 2 + 8
      end
    end
  end

  describe "GET /api/v1/novels/:novel_id/relationship_logs/:id" do
    let!(:log) do
      create(:relationship_log, character_relationship: relationship,
             episode_id: 1, change_description: "敵対から和解")
    end

    it "ログの詳細を返す" do
      get "#{base_path}/#{log.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["id"]).to eq log.id
      expect(body["data"]["change_description"]).to eq "敵対から和解"
      expect(body["data"]["character_relationship"]).to be_present
    end

    it "存在しないIDは404" do
      get "#{base_path}/99999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
