# frozen_string_literal: true

# P2-TE-REQ-001: Characters API Request Spec
# テスター: ミッコ（第2中隊）

require "rails_helper"

RSpec.describe "Api::V1::Characters", type: :request do
  let(:novel_id) { 1 }
  let(:other_novel_id) { 999 }
  let(:base_path) { "/api/v1/novels/#{novel_id}/characters" }

  describe "GET /api/v1/novels/:novel_id/characters" do
    context "キャラクターが存在する場合" do
      before do
        create_list(:character, 3, novel_id: novel_id)
        create(:character, novel_id: other_novel_id) # 別小説のキャラ
      end

      it "指定小説のキャラクター一覧を返す" do
        get base_path
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["success"]).to be true
        expect(body["data"].length).to eq 3
      end

      it "他の小説のキャラクターは含まれない" do
        get base_path
        body = JSON.parse(response.body)
        ids = body["data"].map { |c| c["novel_id"] }.uniq
        expect(ids).to eq [novel_id]
      end

      it "metaにページネーション情報を含む" do
        get base_path
        body = JSON.parse(response.body)
        expect(body["meta"]).to include("total", "page", "per_page")
        expect(body["meta"]["total"]).to eq 3
      end
    end

    context "ページネーション" do
      before { create_list(:character, 25, novel_id: novel_id) }

      it "per_pageで件数を制限できる" do
        get base_path, params: { per_page: 5 }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 5
        expect(body["meta"]["per_page"]).to eq 5
      end

      it "pageでオフセットを指定できる" do
        get base_path, params: { per_page: 10, page: 2 }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 10
        expect(body["meta"]["page"]).to eq 2
      end

      it "per_pageの上限は100" do
        get base_path, params: { per_page: 200 }
        body = JSON.parse(response.body)
        expect(body["meta"]["per_page"]).to eq 100
      end
    end

    context "キャラクターが存在しない場合" do
      it "空配列を返す" do
        get base_path
        body = JSON.parse(response.body)
        expect(body["data"]).to eq []
        expect(body["meta"]["total"]).to eq 0
      end
    end
  end

  describe "GET /api/v1/novels/:novel_id/characters/:id" do
    let!(:character) { create(:character, novel_id: novel_id) }

    context "存在するキャラクター" do
      it "キャラクター詳細を返す" do
        get "#{base_path}/#{character.id}"
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["success"]).to be true
        expect(body["data"]["id"]).to eq character.id
        expect(body["data"]["name"]).to eq character.name
      end
    end

    context "存在しないキャラクター" do
      it "404を返す" do
        get "#{base_path}/99999"
        expect(response).to have_http_status(:not_found)
        body = JSON.parse(response.body)
        expect(body["success"]).to be false
        expect(body["error"]["code"]).to eq "NOT_FOUND"
      end
    end

    context "別の小説のキャラクター" do
      let!(:other_character) { create(:character, novel_id: other_novel_id) }

      it "404を返す" do
        get "#{base_path}/#{other_character.id}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/novels/:novel_id/characters" do
    let(:valid_params) do
      {
        character: {
          name: "新キャラ",
          age: 20,
          appearance: "銀髪ショート",
          personality: "クール",
          role: "仲間"
        }
      }
    end

    context "正常なパラメータ" do
      it "キャラクターを作成できる" do
        expect {
          post base_path, params: valid_params
        }.to change(Character, :count).by(1)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["data"]["name"]).to eq "新キャラ"
        expect(body["data"]["novel_id"]).to eq novel_id
      end
    end

    context "名前なし" do
      it "バリデーションエラーを返す" do
        post base_path, params: { character: { age: 20 } }
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["success"]).to be false
        expect(body["error"]["code"]).to eq "VALIDATION_ERROR"
      end
    end
  end

  describe "PUT /api/v1/novels/:novel_id/characters/:id" do
    let!(:character) { create(:character, novel_id: novel_id, name: "旧名前") }

    context "正常な更新" do
      it "キャラクターを更新できる" do
        put "#{base_path}/#{character.id}", params: { character: { name: "新名前" } }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]["name"]).to eq "新名前"
      end
    end

    context "存在しないキャラクター" do
      it "404を返す" do
        put "#{base_path}/99999", params: { character: { name: "test" } }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "不正なパラメータ" do
      it "名前を空にするとバリデーションエラー" do
        put "#{base_path}/#{character.id}", params: { character: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/novels/:novel_id/characters/:id" do
    let!(:character) { create(:character, novel_id: novel_id) }

    it "キャラクターを削除できる" do
      expect {
        delete "#{base_path}/#{character.id}"
      }.to change(Character, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "存在しないキャラクターの削除は404" do
      delete "#{base_path}/99999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
