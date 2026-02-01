# frozen_string_literal: true

# P2-TE-REQ-003: Foreshadowings API Request Spec
# テスター: ミッコ（第2中隊）
# resolve/abandon統合テスト・resolved_at自動設定・フィルタリング

require "rails_helper"

RSpec.describe "Api::V1::Foreshadowings", type: :request do
  let(:novel_id) { 1 }
  let(:base_path) { "/api/v1/novels/#{novel_id}/foreshadowings" }

  describe "GET /api/v1/novels/:novel_id/foreshadowings" do
    context "フィルタリングなし" do
      before do
        create(:foreshadowing, novel_id: novel_id, status: :planted)
        create(:foreshadowing, novel_id: novel_id, status: :hinted)
        create(:foreshadowing, novel_id: novel_id, status: :resolved)
        create(:foreshadowing, novel_id: 999) # 別小説
      end

      it "指定小説の伏線一覧を返す" do
        get base_path
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 3
      end
    end

    context "statusでフィルタリング" do
      before do
        create(:foreshadowing, novel_id: novel_id, status: :planted)
        create(:foreshadowing, novel_id: novel_id, status: :planted)
        create(:foreshadowing, novel_id: novel_id, status: :resolved)
      end

      it "planted のみ取得できる" do
        get base_path, params: { status: "planted" }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 2
        body["data"].each { |f| expect(f["status"]).to eq "planted" }
      end

      it "resolved のみ取得できる" do
        get base_path, params: { status: "resolved" }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 1
      end
    end

    context "importanceでフィルタリング" do
      before do
        create(:foreshadowing, novel_id: novel_id, importance: :minor)
        create(:foreshadowing, novel_id: novel_id, importance: :critical)
        create(:foreshadowing, novel_id: novel_id, importance: :critical)
      end

      it "criticalのみ取得できる" do
        get base_path, params: { importance: "critical" }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 2
      end
    end

    context "status + importance 複合フィルタ" do
      before do
        create(:foreshadowing, novel_id: novel_id, status: :planted, importance: :critical)
        create(:foreshadowing, novel_id: novel_id, status: :planted, importance: :minor)
        create(:foreshadowing, novel_id: novel_id, status: :resolved, importance: :critical)
      end

      it "両方の条件で絞り込める" do
        get base_path, params: { status: "planted", importance: "critical" }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 1
      end
    end

    context "ページネーション" do
      before { create_list(:foreshadowing, 25, novel_id: novel_id) }

      it "per_pageとpageで制御できる" do
        get base_path, params: { per_page: 10, page: 2 }
        body = JSON.parse(response.body)
        expect(body["data"].length).to eq 10
        expect(body["meta"]["page"]).to eq 2
        expect(body["meta"]["total"]).to eq 25
      end
    end
  end

  describe "GET /api/v1/novels/:novel_id/foreshadowings/:id" do
    let!(:foreshadowing) { create(:foreshadowing, novel_id: novel_id) }

    it "伏線の詳細を返す" do
      get "#{base_path}/#{foreshadowing.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["id"]).to eq foreshadowing.id
      expect(body["data"]["title"]).to eq foreshadowing.title
    end

    it "存在しないIDは404" do
      get "#{base_path}/99999"
      expect(response).to have_http_status(:not_found)
    end

    it "別の小説の伏線は404" do
      other = create(:foreshadowing, novel_id: 999)
      get "#{base_path}/#{other.id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/novels/:novel_id/foreshadowings" do
    let(:valid_params) do
      {
        foreshadowing: {
          title: "謎の預言",
          description: "第1話で語られた預言の意味",
          planted_episode_id: 1,
          status: "planted",
          importance: "major"
        }
      }
    end

    context "正常なパラメータ" do
      it "伏線を作成できる" do
        expect {
          post base_path, params: valid_params
        }.to change(Foreshadowing, :count).by(1)
        expect(response).to have_http_status(:created)
        body = JSON.parse(response.body)
        expect(body["data"]["title"]).to eq "謎の預言"
        expect(body["data"]["novel_id"]).to eq novel_id
        expect(body["data"]["importance"]).to eq "major"
      end
    end

    context "タイトルなし" do
      it "バリデーションエラーを返す" do
        post base_path, params: { foreshadowing: { description: "テスト" } }
        expect(response).to have_http_status(:unprocessable_entity)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq "VALIDATION_ERROR"
      end
    end

    context "不正なstatus値" do
      it "エラーを返す" do
        expect {
          post base_path, params: {
            foreshadowing: { title: "test", status: "invalid_status" }
          }
        }.to raise_error(ArgumentError)
      end
    end

    context "不正なimportance値" do
      it "エラーを返す" do
        expect {
          post base_path, params: {
            foreshadowing: { title: "test", importance: "invalid" }
          }
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "PUT /api/v1/novels/:novel_id/foreshadowings/:id" do
    let!(:foreshadowing) { create(:foreshadowing, novel_id: novel_id, title: "旧タイトル") }

    it "更新できる" do
      put "#{base_path}/#{foreshadowing.id}", params: {
        foreshadowing: { title: "新タイトル", description: "更新後の説明" }
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["data"]["title"]).to eq "新タイトル"
    end

    it "存在しないIDは404" do
      put "#{base_path}/99999", params: { foreshadowing: { title: "test" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/novels/:novel_id/foreshadowings/:id" do
    let!(:foreshadowing) { create(:foreshadowing, novel_id: novel_id) }

    it "削除できる" do
      expect {
        delete "#{base_path}/#{foreshadowing.id}"
      }.to change(Foreshadowing, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end

  # === resolve/abandon 統合テスト ===

  describe "PATCH /api/v1/novels/:novel_id/foreshadowings/:id/resolve" do
    context "planted状態の伏線をresolve" do
      let!(:foreshadowing) do
        create(:foreshadowing, novel_id: novel_id, status: :planted)
      end

      it "resolved状態に変更される" do
        patch "#{base_path}/#{foreshadowing.id}/resolve", params: {
          resolved_episode_id: 10
        }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]["status"]).to eq "resolved"
        expect(body["data"]["resolved_episode_id"]).to eq 10
      end

      it "resolved_episode_idが設定される" do
        patch "#{base_path}/#{foreshadowing.id}/resolve", params: {
          resolved_episode_id: 5
        }
        foreshadowing.reload
        expect(foreshadowing.status).to eq "resolved"
        expect(foreshadowing.resolved_episode_id).to eq 5
      end
    end

    context "hinted状態からresolve" do
      let!(:foreshadowing) do
        create(:foreshadowing, :hinted, novel_id: novel_id)
      end

      it "resolved状態に変更できる" do
        patch "#{base_path}/#{foreshadowing.id}/resolve", params: {
          resolved_episode_id: 8
        }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]["status"]).to eq "resolved"
      end
    end

    context "resolved_episode_idなしでresolve" do
      let!(:foreshadowing) do
        create(:foreshadowing, novel_id: novel_id, status: :planted)
      end

      it "400 BAD_REQUEST を返す（必須パラメータ）" do
        patch "#{base_path}/#{foreshadowing.id}/resolve"
        expect(response).to have_http_status(:bad_request)
        body = JSON.parse(response.body)
        expect(body["error"]["code"]).to eq "BAD_REQUEST"
      end
    end

    context "存在しない伏線をresolve" do
      it "404を返す" do
        patch "#{base_path}/99999/resolve"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /api/v1/novels/:novel_id/foreshadowings/:id/abandon" do
    context "planted状態の伏線をabandon" do
      let!(:foreshadowing) do
        create(:foreshadowing, novel_id: novel_id, status: :planted)
      end

      it "abandoned状態に変更される" do
        patch "#{base_path}/#{foreshadowing.id}/abandon"
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]["status"]).to eq "abandoned"
      end
    end

    context "hinted状態からabandon" do
      let!(:foreshadowing) do
        create(:foreshadowing, :hinted, novel_id: novel_id)
      end

      it "abandoned状態に変更できる" do
        patch "#{base_path}/#{foreshadowing.id}/abandon"
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]["status"]).to eq "abandoned"
      end
    end

    context "既にresolved状態の伏線をabandon" do
      let!(:foreshadowing) do
        create(:foreshadowing, :resolved, novel_id: novel_id)
      end

      it "abandoned状態に変更できる（状態遷移制約未実装のため）" do
        patch "#{base_path}/#{foreshadowing.id}/abandon"
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body["data"]["status"]).to eq "abandoned"
      end
    end

    context "存在しない伏線をabandon" do
      it "404を返す" do
        patch "#{base_path}/99999/abandon"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # === resolve/abandon 連続操作テスト ===

  describe "resolve → abandon の連続操作" do
    let!(:foreshadowing) do
      create(:foreshadowing, novel_id: novel_id, status: :planted)
    end

    it "planted → resolved → abandoned と遷移できる" do
      # resolve
      patch "#{base_path}/#{foreshadowing.id}/resolve", params: { resolved_episode_id: 5 }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["status"]).to eq "resolved"

      # abandon
      patch "#{base_path}/#{foreshadowing.id}/abandon"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["data"]["status"]).to eq "abandoned"

      foreshadowing.reload
      expect(foreshadowing.status).to eq "abandoned"
    end
  end
end
