# frozen_string_literal: true

module Api
  module V1
    class CharacterRelationshipsController < BaseController
      before_action :set_relationship, only: %i[show update destroy]

      # GET /api/v1/novels/:novel_id/character_relationships
      def index
        scope = CharacterRelationship
                  .where(novel_id: @novel_id)
                  .includes(:character, :related_character)
        records, meta = paginate(scope.order(:id))
        render_success(
          records.as_json(
            include: {
              character: { only: %i[id name] },
              related_character: { only: %i[id name] }
            },
            except: %i[created_at updated_at]
          ),
          meta: meta
        )
      end

      # GET /api/v1/novels/:novel_id/character_relationships/:id
      def show
        render_success(
          @relationship.as_json(
            include: {
              character: { only: %i[id name] },
              related_character: { only: %i[id name] }
            }
          )
        )
      end

      # POST /api/v1/novels/:novel_id/character_relationships
      def create
        character_ids = [relationship_params[:character_id], relationship_params[:related_character_id]].compact
        unless character_ids.length == 2 &&
               Character.where(id: character_ids, novel_id: @novel_id).count == 2
          return render_error("指定キャラクターがこの小説に存在しません", status: :not_found)
        end

        relationship = CharacterRelationship.new(
          relationship_params.merge(novel_id: @novel_id)
        )

        if relationship.save
          render_created(relationship.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(relationship))
        end
      end

      # PUT /api/v1/novels/:novel_id/character_relationships/:id
      def update
        if @relationship.update(relationship_params)
          render_success(@relationship.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(@relationship))
        end
      end

      # DELETE /api/v1/novels/:novel_id/character_relationships/:id
      def destroy
        @relationship.destroy!
        head :no_content
      end

      private

      def set_relationship
        @relationship = CharacterRelationship.find_by(id: params[:id], novel_id: @novel_id)
        render_not_found unless @relationship
      end

      def relationship_params
        params.require(:character_relationship).permit(
          :character_id, :related_character_id,
          :relationship_type, :description, :intensity
        )
      end
    end
  end
end
