# frozen_string_literal: true

# ============================================================
# 小説 CRUD API テスト
# タスクID: P1-TE-001
# 作成者: 福田（第1中隊テスト担当）
# 対象: /api/v1/novels
# ============================================================

require 'rails_helper'

RSpec.describe 'Api::V1::Novels', type: :request do
  # --- テストデータ準備 ---
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:auth_headers) { user.create_new_auth_token }
  let(:other_auth_headers) { other_user.create_new_auth_token }

  let!(:novel) do
    create(:novel,
           user: user,
           title: 'テスト小説',
           synopsis: 'テスト概要',
           genre: :fantasy,
           status: :published)
  end

  let!(:other_novel) do
    create(:novel,
           user: other_user,
           title: '他人の小説',
           genre: :romance,
           status: :published)
  end

  let!(:draft_novel) do
    create(:novel,
           user: user,
           title: '下書き小説',
           genre: :fantasy,
           status: :draft)
  end

  let(:valid_params) do
    {
      novel: {
        title: '新規小説',
        synopsis: '新規小説の概要',
        genre: 'fantasy',
        status: 'draft'
      }
    }
  end

  let(:invalid_params) do
    {
      novel: {
        title: nil,
        synopsis: '概要のみ'
      }
    }
  end

  # ========================================================
  # 認証テスト (N-AUTH-001 ~ N-AUTH-007)
  # ========================================================
  describe '認証テスト' do
    # N-AUTH-001
    context '未認証で小説一覧を取得' do
      it '200を返す（公開情報）' do
        get '/api/v1/novels'
        expect(response).to have_http_status(:ok)
      end
    end

    # N-AUTH-002
    context '未認証で小説詳細を取得' do
      it '200を返す（公開情報）' do
        get "/api/v1/novels/#{novel.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    # N-AUTH-003
    context '未認証で小説を作成' do
      it '401を返す' do
        post '/api/v1/novels', params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # N-AUTH-004
    context '未認証で小説を更新' do
      it '401を返す' do
        put "/api/v1/novels/#{novel.id}", params: { novel: { title: '変更' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # N-AUTH-005
    context '未認証で小説を削除' do
      it '401を返す' do
        delete "/api/v1/novels/#{novel.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # N-AUTH-006
    context '他ユーザーの小説を更新' do
      it '403を返す' do
        put "/api/v1/novels/#{other_novel.id}",
            params: { novel: { title: '乗っ取り' } },
            headers: auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    # N-AUTH-007
    context '他ユーザーの小説を削除' do
      it '403を返す' do
        delete "/api/v1/novels/#{other_novel.id}",
               headers: auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  # ========================================================
  # CRUD 正常系テスト (N-CRUD-001 ~ N-CRUD-005)
  # ========================================================
  describe 'CRUD 正常系' do
    # N-CRUD-001
    describe 'GET /api/v1/novels' do
      it '小説一覧を取得できる' do
        get '/api/v1/novels'
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json).to be_an(Array).or have_key('data')
      end
    end

    # N-CRUD-002
    describe 'GET /api/v1/novels/:id' do
      it '小説詳細を取得できる' do
        get "/api/v1/novels/#{novel.id}"
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        expect(json['title'] || json.dig('data', 'title')).to eq('テスト小説')
      end
    end

    # N-CRUD-003
    describe 'POST /api/v1/novels' do
      it '認証済みユーザーが小説を作成できる' do
        expect {
          post '/api/v1/novels', params: valid_params, headers: auth_headers
        }.to change(Novel, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    # N-CRUD-004
    describe 'PUT /api/v1/novels/:id' do
      it '自分の小説を更新できる' do
        put "/api/v1/novels/#{novel.id}",
            params: { novel: { title: '更新後タイトル' } },
            headers: auth_headers
        expect(response).to have_http_status(:ok)

        novel.reload
        expect(novel.title).to eq('更新後タイトル')
      end
    end

    # N-CRUD-005
    describe 'DELETE /api/v1/novels/:id' do
      it '自分の小説を削除できる' do
        expect {
          delete "/api/v1/novels/#{novel.id}", headers: auth_headers
        }.to change(Novel, :count).by(-1)

        expect(response).to have_http_status(:ok).or have_http_status(:no_content)
      end
    end
  end

  # ========================================================
  # CRUD 異常系テスト (N-ERR-001 ~ N-ERR-006)
  # ========================================================
  describe 'CRUD 異常系' do
    # N-ERR-001
    context 'titleなしで作成' do
      it '422を返す' do
        post '/api/v1/novels', params: invalid_params, headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # N-ERR-002
    context '不正なgenre値で作成' do
      it '422を返す' do
        post '/api/v1/novels',
             params: { novel: { title: 'テスト', genre: 'invalid_genre' } },
             headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # N-ERR-003
    context '不正なstatus値で作成' do
      it '422を返す' do
        post '/api/v1/novels',
             params: { novel: { title: 'テスト', status: 'invalid_status' } },
             headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # N-ERR-004
    context '存在しない小説詳細を取得' do
      it '404を返す' do
        get '/api/v1/novels/999999'
        expect(response).to have_http_status(:not_found)
      end
    end

    # N-ERR-005
    context '存在しない小説を更新' do
      it '404を返す' do
        put '/api/v1/novels/999999',
            params: { novel: { title: '更新' } },
            headers: auth_headers
        expect(response).to have_http_status(:not_found)
      end
    end

    # N-ERR-006
    context '存在しない小説を削除' do
      it '404を返す' do
        delete '/api/v1/novels/999999', headers: auth_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # ========================================================
  # ページネーション・フィルタテスト (N-PAGE/N-FILT)
  # ========================================================
  describe 'ページネーション・フィルタ' do
    before do
      # テスト用に追加データを作成
      create_list(:novel, 15, user: user, genre: :fantasy, status: :published)
      create_list(:novel, 5, user: user, genre: :romance, status: :published)
    end

    # N-PAGE-001
    context 'ページネーション: 1ページ目' do
      it '指定件数以内の小説が返る' do
        get '/api/v1/novels', params: { page: 1, per_page: 10 }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        expect(data.length).to be <= 10
      end
    end

    # N-PAGE-002
    context 'ページネーション: 2ページ目' do
      it '2ページ目のデータが返る' do
        get '/api/v1/novels', params: { page: 2, per_page: 5 }
        expect(response).to have_http_status(:ok)
      end
    end

    # N-PAGE-003
    context 'ページネーション: 存在しないページ' do
      it '空配列が返る' do
        get '/api/v1/novels', params: { page: 9999 }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        expect(data).to be_empty
      end
    end

    # N-FILT-001
    context 'ジャンルフィルタ: fantasy' do
      it 'fantasyジャンルのみ返る' do
        get '/api/v1/novels', params: { genre: 'fantasy' }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        data.each do |novel_data|
          expect(novel_data['genre']).to eq('fantasy')
        end
      end
    end

    # N-FILT-002
    context 'ステータスフィルタ: published' do
      it 'publishedステータスのみ返る' do
        get '/api/v1/novels', params: { status: 'published' }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        data.each do |novel_data|
          expect(novel_data['status']).to eq('published')
        end
      end
    end

    # N-FILT-003
    context '複合フィルタ: genre + status' do
      it '条件に一致する小説のみ返る' do
        get '/api/v1/novels', params: { genre: 'fantasy', status: 'published' }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        data.each do |novel_data|
          expect(novel_data['genre']).to eq('fantasy')
          expect(novel_data['status']).to eq('published')
        end
      end
    end

    # N-FILT-004
    context 'フィルタ + ページネーション併用' do
      it 'フィルタ済みデータのページネーションが動作する' do
        get '/api/v1/novels', params: { genre: 'fantasy', page: 1, per_page: 5 }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        expect(data.length).to be <= 5
      end
    end
  end
end
