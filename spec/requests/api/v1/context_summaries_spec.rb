# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::ContextSummaries", type: :request do
  let(:novel_id) { 1 }
  let(:other_novel_id) { 2 }
  let(:episode_id) { 3 }

  let!(:character1) { create(:character, novel_id: novel_id, name: "主人公A") }
  let!(:character2) { create(:character, novel_id: novel_id, name: "仲間B") }
  let!(:other_novel_character) { create(:character, novel_id: other_novel_id, name: "別作品キャラ") }

  describe "GET /api/v1/novels/:novel_id/context_summary" do
    context "episode_id が指定されていない場合" do
      it "400 BAD_REQUEST を返す" do
        get "/api/v1/novels/#{novel_id}/context_summary"
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]["code"]).to eq "BAD_REQUEST"
      end
    end

    context "正常リクエスト" do
      let!(:state1) do
        create(:character_state, character: character1, episode_id: episode_id,
               location: "城", emotional_state: "緊張")
      end
      let!(:state2) do
        create(:character_state, character: character2, episode_id: episode_id,
               location: "森", emotional_state: "平穏")
      end
      let!(:other_episode_state) do
        create(:character_state, character: character1, episode_id: 999,
               location: "別の場所", emotional_state: "怒り")
      end
      let!(:other_novel_state) do
        create(:character_state, character: other_novel_character, episode_id: episode_id,
               location: "異世界", emotional_state: "不安")
      end

      let!(:unresolved_fs) do
        create(:foreshadowing, novel_id: novel_id, title: "未回収伏線",
               status: :planted)
      end
      let!(:resolved_fs) do
        create(:foreshadowing, novel_id: novel_id, title: "回収済伏線",
               status: :resolved, resolved_episode_id: 2)
      end
      let!(:other_novel_fs) do
        create(:foreshadowing, novel_id: other_novel_id, title: "別作品伏線",
               status: :planted)
      end

      let!(:relationship) do
        create(:character_relationship, novel_id: novel_id,
               character: character1, related_character: character2,
               relationship_type: "仲間")
      end

      it "200 を返し、novel_id でスコープされたデータのみ含む" do
        get "/api/v1/novels/#{novel_id}/context_summary", params: { episode_id: episode_id }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true

        data = json["data"]
        expect(data["episode_id"]).to eq episode_id
      end

      it "character_states は指定 novel_id + episode_id のもののみ返す" do
        get "/api/v1/novels/#{novel_id}/context_summary", params: { episode_id: episode_id }

        data = JSON.parse(response.body)["data"]
        states = data["character_states"]
        expect(states.length).to eq 2

        character_names = states.map { |s| s["character"]["name"] }
        expect(character_names).to contain_exactly("主人公A", "仲間B")
        expect(character_names).not_to include("別作品キャラ")
      end

      it "unresolved_foreshadowings は指定 novel_id の未解決伏線のみ返す" do
        get "/api/v1/novels/#{novel_id}/context_summary", params: { episode_id: episode_id }

        data = JSON.parse(response.body)["data"]
        foreshadowings = data["unresolved_foreshadowings"]
        expect(foreshadowings.length).to eq 1
        expect(foreshadowings.first["title"]).to eq "未回収伏線"
      end

      it "character_relationships は指定 novel_id のもののみ返す" do
        get "/api/v1/novels/#{novel_id}/context_summary", params: { episode_id: episode_id }

        data = JSON.parse(response.body)["data"]
        relationships = data["character_relationships"]
        expect(relationships.length).to eq 1
        expect(relationships.first["relationship_type"]).to eq "仲間"
      end
    end

    context "recent_relationship_changes が含まれる" do
      let!(:relationship) do
        create(:character_relationship, novel_id: novel_id,
               character: character1, related_character: character2,
               relationship_type: "仲間")
      end
      let!(:log_in_episode) do
        create(:relationship_log, character_relationship: relationship,
               episode_id: episode_id, change_description: "共闘で絆が深まった")
      end
      let!(:log_other_episode) do
        create(:relationship_log, character_relationship: relationship,
               episode_id: 999, change_description: "別エピソードの変化")
      end

      it "指定エピソードの関係性変化ログのみ返す" do
        get "/api/v1/novels/#{novel_id}/context_summary", params: { episode_id: episode_id }

        data = JSON.parse(response.body)["data"]
        changes = data["recent_relationship_changes"]
        expect(changes.length).to eq 1
        expect(changes.first["change_description"]).to eq "共闘で絆が深まった"
        expect(changes.first["character_relationship"]["character"]["name"]).to eq "主人公A"
      end
    end

    context "該当データがない場合" do
      it "空の配列を返す" do
        get "/api/v1/novels/#{novel_id}/context_summary", params: { episode_id: 9999 }

        expect(response).to have_http_status(:ok)
        data = JSON.parse(response.body)["data"]
        expect(data["character_states"]).to eq []
        expect(data["character_relationships"]).to eq []
        expect(data["recent_relationship_changes"]).to eq []
      end
    end
  end
end
