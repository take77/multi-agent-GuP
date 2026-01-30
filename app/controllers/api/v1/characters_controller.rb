# frozen_string_literal: true

module Api
  module V1
    class CharactersController < BaseController
      before_action :set_character, only: %i[show update destroy]

      # GET /api/v1/novels/:novel_id/characters
      def index
        scope = Character.where(novel_id: @novel_id)
        records, meta = paginate(scope.order(:id))
        render_success(records.as_json(except: %i[created_at updated_at]), meta: meta)
      end

      # GET /api/v1/novels/:novel_id/characters/:id
      def show
        render_success(@character.as_json)
      end

      # POST /api/v1/novels/:novel_id/characters
      def create
        character = Character.new(character_params.merge(novel_id: @novel_id))

        if character.save
          render_created(character.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(character))
        end
      end

      # PUT /api/v1/novels/:novel_id/characters/:id
      def update
        if @character.update(character_params)
          render_success(@character.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(@character))
        end
      end

      # DELETE /api/v1/novels/:novel_id/characters/:id
      def destroy
        @character.destroy!
        head :no_content
      end

      private

      def set_character
        @character = Character.find_by(id: params[:id], novel_id: @novel_id)
        render_not_found unless @character
      end

      def character_params
        params.require(:character).permit(
          :name, :age, :appearance, :abilities,
          :personality, :speech_style, :background, :role
        )
      end
    end
  end
end
