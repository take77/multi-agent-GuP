# frozen_string_literal: true

module Api
  module V1
    class RelationshipLogsController < BaseController
      # GET /api/v1/novels/:novel_id/relationship_logs
      # 関係性変化履歴の取得
      def index
        scope = RelationshipLog
                  .joins(character_relationship: :character)
                  .where(characters: { novel_id: @novel_id })
                  .includes(character_relationship: %i[character related_character])
        scope = scope.where(episode_id: params[:episode_id]) if params[:episode_id].present?
        records, meta = paginate(scope.order(created_at: :desc))
        render_success(
          records.as_json(
            include: {
              character_relationship: {
                only: %i[id relationship_type],
                include: {
                  character: { only: %i[id name] },
                  related_character: { only: %i[id name] }
                }
              }
            },
            except: %i[created_at updated_at]
          ),
          meta: meta
        )
      end

      # GET /api/v1/novels/:novel_id/relationship_logs/:id
      def show
        log = RelationshipLog
                .joins(character_relationship: :character)
                .where(characters: { novel_id: @novel_id })
                .includes(character_relationship: %i[character related_character])
                .find_by(id: params[:id])
        if log
          render_success(
            log.as_json(
              include: {
                character_relationship: {
                  include: {
                    character: { only: %i[id name] },
                    related_character: { only: %i[id name] }
                  }
                }
              }
            )
          )
        else
          render_not_found
        end
      end
    end
  end
end
