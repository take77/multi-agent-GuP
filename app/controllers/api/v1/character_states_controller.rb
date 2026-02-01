# frozen_string_literal: true

module Api
  module V1
    class CharacterStatesController < BaseController
      before_action :set_character_state, only: %i[show update destroy]
      before_action :set_timeline_character, only: %i[timeline]

      # GET /api/v1/novels/:novel_id/character_states
      # エピソードごとのキャラクター状態一覧
      #
      # パラメータ:
      #   episode_id       - 特定エピソードでフィルタ
      #   character_id     - 特定キャラクターでフィルタ
      #   from_episode     - エピソード範囲の開始（inclusive）
      #   to_episode       - エピソード範囲の終了（inclusive）
      def index
        scope = CharacterState
                  .joins(:character)
                  .where(characters: { novel_id: @novel_id })
                  .includes(:character)
        scope = scope.where(episode_id: params[:episode_id]) if params[:episode_id].present?
        scope = scope.where(character_id: params[:character_id]) if params[:character_id].present?
        scope = scope.where(episode_id: params[:from_episode].to_i..) if params[:from_episode].present?
        scope = scope.where(episode_id: ..params[:to_episode].to_i) if params[:to_episode].present?
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

      # GET /api/v1/novels/:novel_id/characters/:character_id/timeline
      # 特定キャラクターの状態変遷を時系列（episode_id昇順）で取得
      def timeline
        scope = @timeline_character.character_states.order(:episode_id)
        scope = scope.where(episode_id: params[:from_episode].to_i..) if params[:from_episode].present?
        scope = scope.where(episode_id: ..params[:to_episode].to_i) if params[:to_episode].present?
        records, meta = paginate(scope)

        render_success(
          records.as_json(except: %i[created_at updated_at]),
          meta: meta
        )
      end

      private

      def set_timeline_character
        @timeline_character = Character.find_by(id: params[:character_id], novel_id: @novel_id)
        render_not_found unless @timeline_character
      end

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
