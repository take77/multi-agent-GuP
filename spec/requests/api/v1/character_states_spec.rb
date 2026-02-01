# frozen_string_literal: true

# P2-TE-REQ-002: CharacterStates API Request Spec
# テスター: ミッコ（第2中隊）
# 範囲指定フィルタリング・CRUD・エラーケース

require "rails_helper"

RSpec.describe "Api::V1::CharacterStates", type: :request do
  let(:novel_id) { 1 }
  let(:base_path) { "/api/v1/novels/#{novel_id}/character_states" }
  let!(:character) { create(:character, novel_id: novel_id) }
  let!(:character2) { create(:character, novel_id: novel_id) }

  describe "GET /api/v1/novels/:novel_id/character_states" do
    context "フィルタリングなし" do
      before do
        create(:character_state, character: character, episode_id: 1)
        create(:character_state, character: character, episode_id: 2)
        create(:character_state, character: character2, episode_id: 1)
      end

      it "指定小説の全キャラクター状態を返す" do
        get base_path
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["success"]).to be true
        expect(body["data"].length).to eq 3
      end

      it "キャラクター情報が含まれる" do
        get base_path
        body = JSON.parse(response.body)
        first = body["data"].first
        expect(first["character"]).to include("id", "name")
      end
    end

    context "episode_idでフィルタリング" do
      before do
        create(:character_state, character: character, episode_id: 1)
        create(:character_state, character: character, episode_id: 2)
        create(:character_state, character: character, episode_id: 3)
      end

      it "特定エピソードの状態のみ返す" do
        get base_path, params: { episode_id: 2 }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 1
        expect(body["data"].first["episode_id"]).to eq 2
      end
    end

    context "character_idでフィルタリング" do
      before do
        create(:character_state, character: character, episode_id: 1)
        create(:character_state, character: character, episode_id: 2)
        create(:character_state, character: character2, episode_id: 1)
      end

      it "特定キャラクターの状態のみ返す" do
        get base_path, params: { character_id: character.id }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 2
        body["data"].each do |state|
          expect(state["character_id"]).to eq character.id
        end
      end
    end

    context "episode_id + character_id 複合フィルタ" do
      before do
        create(:character_state, character: character, episode_id: 1)
        create(:character_state, character: character, episode_id: 2)
        create(:character_state, character: character2, episode_id: 1)
      end

      it "両方の条件で絞り込める" do
        get base_path, params: { episode_id: 1, character_id: character.id }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 1
        expect(body["data"].first["character_id"]).to eq character.id
        expect(body["data"].first["episode_id"]).to eq 1
      end
    end

    context "別の小説のキャラクター状態" do
      let!(:other_character) { create(:character, novel_id: 999) }

      before do
        create(:character_state, character: other_character, episode_id: 1)
        create(:character_state, character: character, episode_id: 1)
      end

      it "他の小説のデータは返さない" do
        get base_path
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 1
      end
    end

    context "ページネーション" do
      before do
        15.times { |i| create(:character_state, character: character, episode_id: i + 1) }
      end

      it "per_pageで件数を制限できる" do
        get base_path, params: { per_page: 5 }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 5
        expect(body["meta"]["total"]).to eq 15
      end
    end

    context "from_episode / to_episode 範囲指定" do
      before do
        (1..10).each do |ep|
          create(:character_state, character: character, episode_id: ep)
        end
      end

      it "from_episode で開始エピソード以降のみ返す" do
        get base_path, params: { from_episode: 5 }
        body = JSON.parse(response.body)
        episode_ids = body["data"].map { |s| s["episode_id"] }
        expect(episode_ids).to all(be >= 5)
        expect(episode_ids.length).to eq 6
      end

      it "to_episode で終了エピソード以前のみ返す" do
        get base_path, params: { to_episode: 3 }
        body = JSON.parse(response.body)
        episode_ids = body["data"].map { |s| s["episode_id"] }
        expect(episode_ids).to all(be <= 3)
        expect(episode_ids.length).to eq 3
      end

      it "from_episode + to_episode で範囲指定" do
        get base_path, params: { from_episode: 3, to_episode: 7 }
        body = JSON.parse(response.body)
        episode_ids = body["data"].map { |s| s["episode_id"] }
        expect(episode_ids).to all(be_between(3, 7))
        expect(episode_ids.length).to eq 5
      end
    end
  end

  describe "GET /api/v1/novels/:novel_id/characters/:character_id/timeline" do
    before do
      [1, 3, 5, 7, 10].each do |ep|
        create(:character_state, character: character, episode_id: ep,
               location: "場所#{ep}", emotional_state: "状態#{ep}")
      end
    end

    it "episode_id 昇順で状態変遷を返す" do
      get "/api/v1/novels/#{novel_id}/characters/#{character.id}/timeline"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["success"]).to be true
      episode_ids = body["data"].map { |s| s["episode_id"] }
      expect(episode_ids).to eq [1, 3, 5, 7, 10]
    end

    it "from_episode / to_episode で範囲絞り込み" do
      get "/api/v1/novels/#{novel_id}/characters/#{character.id}/timeline",
          params: { from_episode: 3, to_episode: 7 }
      body = JSON.parse(response.body)
      episode_ids = body["data"].map { |s| s["episode_id"] }
      expect(episode_ids).to eq [3, 5, 7]
    end

    it "存在しないキャラクターIDで 404" do
      get "/api/v1/novels/#{novel_id}/characters/9999/timeline"
      expect(response).to have_http_status(:not_found)
    end

    it "別 novel_id のキャラクターには 404" do
      other_char = create(:character, novel_id: 999)
      get "/api/v1/novels/#{novel_id}/characters/#{other_char.id}/timeline"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/v1/novels/:novel_id/character_states/:id" do
    let!(:state) { create(:character_state, character: character, episode_id: 1) }

    it "キャラクター状態の詳細を返す" do
      get "#{base_path}/#{state.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["id"]).to eq state.id
      expect(body["data"]["character"]).to be_present
    end

    it "存在しないIDは404" do
      get "#{base_path}/99999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/novels/:novel_id/character_states" do
    let(:valid_params) do
      {
        character_state: {
          character_id: character.id,
          episode_id: 1,
          location: "森の奥",
          emotional_state: "緊張",
          physical_state: "軽傷",
          knowledge: "敵の弱点を発見",
          inventory: ["魔法の杖", "回復薬"],
          notes: "戦闘後"
        }
      }
    end

    context "正常なパラメータ" do
      it "キャラクター状態を作成できる" do
        expect {
          post base_path, params: valid_params
        }.to change(CharacterState, :count).by(1)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["data"]["location"]).to eq "森の奥"
        expect(body["data"]["inventory"]).to eq ["魔法の杖", "回復薬"]
      end
    end

    context "存在しないキャラクターID" do
      it "404を返す" do
        post base_path, params: {
          character_state: { character_id: 99999, episode_id: 1 }
        }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "別の小説のキャラクターID" do
      let!(:other_character) { create(:character, novel_id: 999) }

      it "404を返す" do
        post base_path, params: {
          character_state: { character_id: other_character.id, episode_id: 1 }
        }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "同一キャラクター・同一エピソードの重複" do
      before { create(:character_state, character: character, episode_id: 1) }

      it "バリデーションエラーを返す" do
        post base_path, params: {
          character_state: { character_id: character.id, episode_id: 1 }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /api/v1/novels/:novel_id/character_states/:id" do
    let!(:state) do
      create(:character_state, character: character, episode_id: 1, location: "王都")
    end

    it "更新できる" do
      put "#{base_path}/#{state.id}", params: {
        character_state: { location: "魔王城", emotional_state: "決意" }
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["location"]).to eq "魔王城"
      expect(body["data"]["emotional_state"]).to eq "決意"
    end

    it "存在しないIDは404" do
      put "#{base_path}/99999", params: { character_state: { location: "test" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/novels/:novel_id/character_states/:id" do
    let!(:state) { create(:character_state, character: character, episode_id: 1) }

    it "削除できる" do
      expect {
        delete "#{base_path}/#{state.id}"
      }.to change(CharacterState, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "存在しないIDは404" do
      delete "#{base_path}/99999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
