# frozen_string_literal: true

# ============================================================
# エピソード CRUD API テスト
# タスクID: P1-TE-001
# 作成者: 福田（第1中隊テスト担当）
# 対象: /api/v1/novels/:novel_id/episodes
# ============================================================

require 'rails_helper'

RSpec.describe 'Api::V1::Episodes', type: :request do
  # --- テストデータ準備 ---
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:auth_headers) { user.create_new_auth_token }
  let(:other_auth_headers) { other_user.create_new_auth_token }

  let!(:novel) { create(:novel, user: user, status: :published) }
  let!(:other_novel) { create(:novel, user: other_user, status: :published) }
  let!(:chapter) { create(:chapter, novel: novel, chapter_number: 1) }

  let!(:episode) do
    create(:episode,
           novel: novel,
           chapter: chapter,
           title: '第1話 始まり',
           body: '本文テキスト',
           episode_number: 1,
           status: :published,
           word_count: 1000)
  end

  let!(:other_episode) do
    create(:episode, novel: other_novel, episode_number: 1, status: :published)
  end

  let(:base_path) { "/api/v1/novels/#{novel.id}/episodes" }
  let(:other_base_path) { "/api/v1/novels/#{other_novel.id}/episodes" }

  let(:valid_params) do
    {
      episode: {
        title: '新規エピソード',
        body: '新規エピソードの本文',
        episode_number: 2,
        status: 'draft'
      }
    }
  end

  # ========================================================
  # 認証テスト (E-AUTH-001 ~ E-AUTH-008)
  # ========================================================
  describe '認証テスト' do
    # E-AUTH-001
    context '未認証でエピソード一覧を取得' do
      it '200を返す（公開情報）' do
        get base_path
        expect(response).to have_http_status(:ok)
      end
    end

    # E-AUTH-002
    context '未認証でエピソード詳細を取得' do
      it '200を返す（公開情報）' do
        get "#{base_path}/#{episode.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    # E-AUTH-003
    context '未認証でエピソードを作成' do
      it '401を返す' do
        post base_path, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # E-AUTH-004
    context '未認証でエピソードを更新' do
      it '401を返す' do
        put "#{base_path}/#{episode.id}",
            params: { episode: { title: '変更' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # E-AUTH-005
    context '未認証でエピソードを削除' do
      it '401を返す' do
        delete "#{base_path}/#{episode.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # E-AUTH-006
    context '他ユーザーの小説にエピソードを作成' do
      it '403を返す' do
        post other_base_path,
             params: valid_params,
             headers: auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    # E-AUTH-007
    context '他ユーザーの小説のエピソードを更新' do
      it '403を返す' do
        put "#{other_base_path}/#{other_episode.id}",
            params: { episode: { title: '乗っ取り' } },
            headers: auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    # E-AUTH-008
    context '他ユーザーの小説のエピソードを削除' do
      it '403を返す' do
        delete "#{other_base_path}/#{other_episode.id}",
               headers: auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  # ========================================================
  # CRUD 正常系テスト (E-CRUD-001 ~ E-CRUD-006)
  # ========================================================
  describe 'CRUD 正常系' do
    # E-CRUD-001
    describe 'GET /api/v1/novels/:novel_id/episodes' do
      it 'エピソード一覧を取得できる' do
        get base_path
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        expect(data).not_to be_empty
      end
    end

    # E-CRUD-002
    describe 'GET /api/v1/novels/:novel_id/episodes/:id' do
      it 'エピソード詳細を取得できる（本文含む）' do
        get "#{base_path}/#{episode.id}"
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        episode_data = json.is_a?(Hash) && json.key?('data') ? json['data'] : json
        expect(episode_data['title']).to eq('第1話 始まり')
        expect(episode_data).to have_key('body')
      end
    end

    # E-CRUD-003
    describe 'POST /api/v1/novels/:novel_id/episodes' do
      it 'エピソードを新規作成できる' do
        expect {
          post base_path, params: valid_params, headers: auth_headers
        }.to change(Episode, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    # E-CRUD-004
    describe 'POST (chapter_id付き)' do
      it 'chapter_id付きでエピソードを作成できる' do
        params = {
          episode: {
            title: '第2話',
            body: '本文',
            episode_number: 3,
            chapter_id: chapter.id,
            status: 'draft'
          }
        }
        post base_path, params: params, headers: auth_headers
        expect(response).to have_http_status(:created)

        json = response.parsed_body
        episode_data = json.is_a?(Hash) && json.key?('data') ? json['data'] : json
        expect(episode_data['chapter_id']).to eq(chapter.id)
      end
    end

    # E-CRUD-005
    describe 'PUT /api/v1/novels/:novel_id/episodes/:id' do
      it 'エピソードを更新できる' do
        put "#{base_path}/#{episode.id}",
            params: { episode: { title: '更新タイトル', body: '更新本文' } },
            headers: auth_headers
        expect(response).to have_http_status(:ok)

        episode.reload
        expect(episode.title).to eq('更新タイトル')
      end
    end

    # E-CRUD-006
    describe 'DELETE /api/v1/novels/:novel_id/episodes/:id' do
      it 'エピソードを削除できる' do
        expect {
          delete "#{base_path}/#{episode.id}", headers: auth_headers
        }.to change(Episode, :count).by(-1)

        expect(response).to have_http_status(:ok).or have_http_status(:no_content)
      end
    end
  end

  # ========================================================
  # CRUD 異常系テスト (E-ERR-001 ~ E-ERR-005)
  # ========================================================
  describe 'CRUD 異常系' do
    # E-ERR-001
    context 'titleなしで作成' do
      it '422を返す' do
        post base_path,
             params: { episode: { body: '本文のみ', episode_number: 99 } },
             headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # E-ERR-002
    context 'episode_numberなしで作成' do
      it '422を返す' do
        post base_path,
             params: { episode: { title: 'タイトルのみ', body: '本文' } },
             headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # E-ERR-003
    context '存在しない小説のエピソード一覧を取得' do
      it '404を返す' do
        get '/api/v1/novels/999999/episodes'
        expect(response).to have_http_status(:not_found)
      end
    end

    # E-ERR-004
    context '存在しないエピソード詳細を取得' do
      it '404を返す' do
        get "#{base_path}/999999"
        expect(response).to have_http_status(:not_found)
      end
    end

    # E-ERR-005
    context '存在しないchapter_idを指定して作成' do
      it '422を返す' do
        post base_path,
             params: {
               episode: {
                 title: 'テスト',
                 body: '本文',
                 episode_number: 99,
                 chapter_id: 999999
               }
             },
             headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # ========================================================
  # ページネーションテスト (E-PAGE-001 ~ E-PAGE-002)
  # ========================================================
  describe 'ページネーション' do
    before do
      create_list(:episode, 15, novel: novel, status: :published)
    end

    # E-PAGE-001
    context 'ページネーション: 1ページ目' do
      it '指定件数以内のエピソードが返る' do
        get base_path, params: { page: 1, per_page: 10 }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        expect(data.length).to be <= 10
      end
    end

    # E-PAGE-002
    context 'ページネーション: 存在しないページ' do
      it '空配列が返る' do
        get base_path, params: { page: 9999 }
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        expect(data).to be_empty
      end
    end
  end
end
