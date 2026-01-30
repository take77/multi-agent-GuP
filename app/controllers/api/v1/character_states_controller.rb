# frozen_string_literal: true

module Api
  module V1
    class CharacterStatesController < BaseController
      before_action :set_character_state, only: %i[show update destroy]

      # GET /api/v1/novels/:novel_id/character_states
      # エピソードごとのキャラクター状態一覧
      def index
        scope = CharacterState
                  .joins(:character)
                  .where(characters: { novel_id: @novel_id })
                  .includes(:character)
        scope = scope.where(episode_id: params[:episode_id]) if params[:episode_id].present?
        scope = scope.where(character_id: params[:character_id]) if params[:character_id].present?
        records, meta = paginate(scope.order(:character_id, :episode_id))
        render_success(
          records.as_json(
            include: { character: { only: %i[id name] } },
            except: %i[created_at updated_at]
          ),
          meta: meta
        )
      end

      # GET /api/v1/novels/:novel_id/character_states/:id
      def show
        render_success(
          @character_state.as_json(
            include: { character: { only: %i[id name] } }
          )
        )
      end

      # POST /api/v1/novels/:novel_id/character_states
      def create
        unless Character.exists?(id: character_state_params[:character_id], novel_id: @novel_id)
          return render_error("指定キャラクターがこの小説に存在しません", status: :not_found)
        end

        character_state = CharacterState.new(character_state_params)

        if character_state.save
          render_created(character_state.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(character_state))
        end
      end

      # PUT /api/v1/novels/:novel_id/character_states/:id
      def update
        if @character_state.update(character_state_params)
          render_success(@character_state.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(@character_state))
        end
      end

      # DELETE /api/v1/novels/:novel_id/character_states/:id
      def destroy
        @character_state.destroy!
        head :no_content
      end

      private

      def set_character_state
        @character_state = CharacterState
                             .joins(:character)
                             .where(characters: { novel_id: @novel_id })
                             .find_by(id: params[:id])
        render_not_found unless @character_state
      end

      def character_state_params
        params.require(:character_state).permit(
          :character_id, :episode_id, :location,
          :emotional_state, :physical_state, :knowledge,
          :notes, inventory: []
        )
      end
    end
  end
end
