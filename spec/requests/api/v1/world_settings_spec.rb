# frozen_string_literal: true

# P2-TE-REQ-005: WorldSettings API Request Spec
# テスター: ミッコ（第2中隊）

require "rails_helper"

RSpec.describe "Api::V1::WorldSettings", type: :request do
  let(:novel_id) { 1 }
  let(:base_path) { "/api/v1/novels/#{novel_id}/world_settings" }

  describe "GET /api/v1/novels/:novel_id/world_settings" do
    before do
      create(:world_setting, novel_id: novel_id, category: "geography")
      create(:world_setting, novel_id: novel_id, category: "magic")
      create(:world_setting, novel_id: novel_id, category: "geography")
      create(:world_setting, novel_id: 999) # 別小説
    end

    it "指定小説の世界観設定一覧を返す" do
      get base_path
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"].length).to eq 3
    end

    it "categoryでフィルタリングできる" do
      get base_path, params: { category: "geography" }
      body = JSON.parse(response.body)
      expect(body["data"].length).to eq 2
      body["data"].each { |ws| expect(ws["category"]).to eq "geography" }
    end

    it "ページネーションが機能する" do
      get base_path, params: { per_page: 2 }
      body = JSON.parse(response.body)
      expect(body["data"].length).to eq 2
      expect(body["meta"]["total"]).to eq 3
    end
  end

  describe "GET /api/v1/novels/:novel_id/world_settings/:id" do
    let!(:setting) { create(:world_setting, novel_id: novel_id) }

    it "詳細を返す" do
      get "#{base_path}/#{setting.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["id"]).to eq setting.id
    end

    it "存在しないIDは404" do
      get "#{base_path}/99999"
      expect(response).to have_http_status(:not_found)
    end

    it "別小説の設定は404" do
      other = create(:world_setting, novel_id: 999)
      get "#{base_path}/#{other.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/novels/:novel_id/world_settings" do
    context "正常なパラメータ" do
      it "世界観設定を作成できる" do
        expect {
          post base_path, params: {
            world_setting: {
              category: "magic",
              title: "魔法体系",
              description: "四大元素に基づく魔法体系",
              details: { elements: %w[火 水 風 土] }.to_json
            }
          }
        }.to change(WorldSetting, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "不正なcategory" do
      it "バリデーションエラーを返す" do
        post base_path, params: {
          world_setting: { category: "invalid", title: "test" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "タイトルなし" do
      it "バリデーションエラーを返す" do
        post base_path, params: {
          world_setting: { category: "magic" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "categoryなし" do
      it "バリデーションエラーを返す" do
        post base_path, params: {
          world_setting: { title: "test" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /api/v1/novels/:novel_id/world_settings/:id" do
    let!(:setting) do
      create(:world_setting, novel_id: novel_id, title: "旧タイトル")
    end

    it "更新できる" do
      put "#{base_path}/#{setting.id}", params: {
        world_setting: { title: "新タイトル" }
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["title"]).to eq "新タイトル"
    end

    it "不正なcategoryへの変更はエラー" do
      put "#{base_path}/#{setting.id}", params: {
        world_setting: { category: "invalid" }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "DELETE /api/v1/novels/:novel_id/world_settings/:id" do
    let!(:setting) { create(:world_setting, novel_id: novel_id) }

    it "削除できる" do
      expect {
        delete "#{base_path}/#{setting.id}"
      }.to change(WorldSetting, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
