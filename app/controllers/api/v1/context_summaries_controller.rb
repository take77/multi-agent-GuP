# frozen_string_literal: true

module Api
  module V1
    class ContextSummariesController < BaseController
      # GET /api/v1/novels/:novel_id/context_summary?episode_id=XX
      #
      # 指定エピソード時点でのコンテキスト要約API
      # 第3中隊（AI生成チーム）が利用する最重要インターフェース
      #
      # レスポンス:
      #   - character_states: 全キャラクターの現在状態
      #   - unresolved_foreshadowings: 未回収伏線一覧
      #   - character_relationships: キャラクター間関係性一覧
      #   - recent_relationship_changes: 直近の関係性変化
      def show
        episode_id = params[:episode_id]

        unless episode_id.present?
          return render_error("episode_id は必須パラメータです", status: :bad_request)
        end

        # N+1防止: includes で一括読み込み
        character_states = CharacterState
                             .where(episode_id: episode_id)
                             .joins(:character)
                             .where(characters: { novel_id: @novel_id })
                             .includes(:character)

        unresolved_foreshadowings = Foreshadowing
                                      .where(novel_id: @novel_id)
                                      .where.not(status: %i[resolved abandoned])

        character_relationships = CharacterRelationship
                                    .where(novel_id: @novel_id)
                                    .includes(:character, :related_character)

        recent_relationship_changes = RelationshipLog
                                        .where(episode_id: episode_id)
                                        .joins(character_relationship: :character)
                                        .where(characters: { novel_id: @novel_id })
                                        .includes(
                                          character_relationship: %i[character related_character]
                                        )

        render_success(
          {
            episode_id: episode_id.to_i,
            character_states: character_states.as_json(
              include: { character: { only: %i[id name role] } },
              except: %i[created_at updated_at]
            ),
            unresolved_foreshadowings: unresolved_foreshadowings.as_json(
              except: %i[created_at updated_at]
            ),
            character_relationships: character_relationships.as_json(
              include: {
                character: { only: %i[id name] },
                related_character: { only: %i[id name] }
              },
              except: %i[created_at updated_at]
            ),
            recent_relationship_changes: recent_relationship_changes.as_json(
              include: {
                character_relationship: {
                  only: %i[id],
                  include: {
                    character: { only: %i[id name] },
                    related_character: { only: %i[id name] }
                  }
                }
              },
              except: %i[created_at updated_at]
            )
          }
        )
      end
    end
  end
end
