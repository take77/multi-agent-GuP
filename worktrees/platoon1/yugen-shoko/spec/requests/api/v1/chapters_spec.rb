# frozen_string_literal: true

# ============================================================
# 章 CRUD API テスト
# タスクID: P1-TE-001
# 作成者: 福田（第1中隊テスト担当）
# 対象: /api/v1/novels/:novel_id/chapters
# ============================================================

require 'rails_helper'

RSpec.describe 'Api::V1::Chapters', type: :request do
  # --- テストデータ準備 ---
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:auth_headers) { user.create_new_auth_token }
  let(:other_auth_headers) { other_user.create_new_auth_token }

  let!(:novel) { create(:novel, user: user, status: :published) }
  let!(:other_novel) { create(:novel, user: other_user, status: :published) }

  let!(:chapter) do
    create(:chapter,
           novel: novel,
           title: '第一章 出発',
           chapter_number: 1,
           synopsis: '物語の始まり')
  end

  let!(:other_chapter) do
    create(:chapter, novel: other_novel, chapter_number: 1)
  end

  let(:base_path) { "/api/v1/novels/#{novel.id}/chapters" }
  let(:other_base_path) { "/api/v1/novels/#{other_novel.id}/chapters" }

  let(:valid_params) do
    {
      chapter: {
        title: '第二章 旅立ち',
        chapter_number: 2,
        synopsis: '新たな冒険の始まり'
      }
    }
  end

  # ========================================================
  # 認証テスト (C-AUTH-001 ~ C-AUTH-008)
  # ========================================================
  describe '認証テスト' do
    # C-AUTH-001
    context '未認証で章一覧を取得' do
      it '200を返す' do
        get base_path
        expect(response).to have_http_status(:ok)
      end
    end

    # C-AUTH-002
    context '未認証で章詳細を取得' do
      it '200を返す' do
        get "#{base_path}/#{chapter.id}"
        expect(response).to have_http_status(:ok)
      end
    end

    # C-AUTH-003
    context '未認証で章を作成' do
      it '401を返す' do
        post base_path, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # C-AUTH-004
    context '未認証で章を更新' do
      it '401を返す' do
        put "#{base_path}/#{chapter.id}",
            params: { chapter: { title: '変更' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # C-AUTH-005
    context '未認証で章を削除' do
      it '401を返す' do
        delete "#{base_path}/#{chapter.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # C-AUTH-006
    context '他ユーザーの小説に章を作成' do
      it '403を返す' do
        post other_base_path,
             params: valid_params,
             headers: auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    # C-AUTH-007
    context '他ユーザーの小説の章を更新' do
      it '403を返す' do
        put "#{other_base_path}/#{other_chapter.id}",
            params: { chapter: { title: '乗っ取り' } },
            headers: auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    # C-AUTH-008
    context '他ユーザーの小説の章を削除' do
      it '403を返す' do
        delete "#{other_base_path}/#{other_chapter.id}",
               headers: auth_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  # ========================================================
  # CRUD 正常系テスト (C-CRUD-001 ~ C-CRUD-005)
  # ========================================================
  describe 'CRUD 正常系' do
    # C-CRUD-001
    describe 'GET /api/v1/novels/:novel_id/chapters' do
      it '章一覧を取得できる' do
        get base_path
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        data = json.is_a?(Array) ? json : json['data']
        expect(data).not_to be_empty
      end
    end

    # C-CRUD-002
    describe 'GET /api/v1/novels/:novel_id/chapters/:id' do
      it '章詳細を取得できる' do
        get "#{base_path}/#{chapter.id}"
        expect(response).to have_http_status(:ok)

        json = response.parsed_body
        chapter_data = json.is_a?(Hash) && json.key?('data') ? json['data'] : json
        expect(chapter_data['title']).to eq('第一章 出発')
        expect(chapter_data['chapter_number']).to eq(1)
      end
    end

    # C-CRUD-003
    describe 'POST /api/v1/novels/:novel_id/chapters' do
      it '章を新規作成できる' do
        expect {
          post base_path, params: valid_params, headers: auth_headers
        }.to change(Chapter, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    # C-CRUD-004
    describe 'PUT /api/v1/novels/:novel_id/chapters/:id' do
      it '章を更新できる' do
        put "#{base_path}/#{chapter.id}",
            params: { chapter: { title: '更新: 第一章', synopsis: '更新後の概要' } },
            headers: auth_headers
        expect(response).to have_http_status(:ok)

        chapter.reload
        expect(chapter.title).to eq('更新: 第一章')
        expect(chapter.synopsis).to eq('更新後の概要')
      end
    end

    # C-CRUD-005
    describe 'DELETE /api/v1/novels/:novel_id/chapters/:id' do
      it '章を削除できる' do
        expect {
          delete "#{base_path}/#{chapter.id}", headers: auth_headers
        }.to change(Chapter, :count).by(-1)

        expect(response).to have_http_status(:ok).or have_http_status(:no_content)
      end
    end
  end

  # ========================================================
  # CRUD 異常系テスト (C-ERR-001 ~ C-ERR-005)
  # ========================================================
  describe 'CRUD 異常系' do
    # C-ERR-001
    context 'titleなしで作成' do
      it '422を返す' do
        post base_path,
             params: { chapter: { chapter_number: 99 } },
             headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # C-ERR-002
    context 'chapter_numberなしで作成' do
      it '422を返す' do
        post base_path,
             params: { chapter: { title: 'タイトルのみ' } },
             headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # C-ERR-003
    context '重複するchapter_numberで作成' do
      it '422を返す（ユニーク制約違反）' do
        post base_path,
             params: {
               chapter: {
                 title: '重複章',
                 chapter_number: 1  # chapter already has chapter_number: 1
               }
             },
             headers: auth_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    # C-ERR-004
    context '存在しない小説の章一覧を取得' do
      it '404を返す' do
        get '/api/v1/novels/999999/chapters'
        expect(response).to have_http_status(:not_found)
      end
    end

    # C-ERR-005
    context '存在しない章詳細を取得' do
      it '404を返す' do
        get "#{base_path}/999999"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
