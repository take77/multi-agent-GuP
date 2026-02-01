# frozen_string_literal: true

module Api
  module V1
    class ForeshadowingsController < BaseController
      before_action :set_foreshadowing, only: %i[show update destroy resolve abandon]

      # GET /api/v1/novels/:novel_id/foreshadowings
      def index
        scope = Foreshadowing.where(novel_id: @novel_id)
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(importance: params[:importance]) if params[:importance].present?
        records, meta = paginate(scope.order(:id))
        render_success(records.as_json(except: %i[created_at updated_at]), meta: meta)
      end

      # GET /api/v1/novels/:novel_id/foreshadowings/:id
      def show
        render_success(@foreshadowing.as_json)
      end

      # POST /api/v1/novels/:novel_id/foreshadowings
      def create
        foreshadowing = Foreshadowing.new(foreshadowing_params.merge(novel_id: @novel_id))

        if foreshadowing.save
          render_created(foreshadowing.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(foreshadowing))
        end
      end

      # PUT /api/v1/novels/:novel_id/foreshadowings/:id
      def update
        if @foreshadowing.update(foreshadowing_params)
          render_success(@foreshadowing.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(@foreshadowing))
        end
      end

      # DELETE /api/v1/novels/:novel_id/foreshadowings/:id
      def destroy
        @foreshadowing.destroy!
        head :no_content
      end

      # PATCH /api/v1/novels/:novel_id/foreshadowings/:id/resolve
      def resolve
        unless params[:resolved_episode_id].present?
          return render_error("resolved_episode_id は必須パラメータです", status: :bad_request)
        end

        if @foreshadowing.update(
          status: :resolved,
          resolved_episode_id: params[:resolved_episode_id]
        )
          render_success(@foreshadowing.as_json)
        else
          render_error("ステータス変更に失敗しました", details: format_errors(@foreshadowing))
        end
      end

      # PATCH /api/v1/novels/:novel_id/foreshadowings/:id/abandon
      def abandon
        if @foreshadowing.update(status: :abandoned)
          render_success(@foreshadowing.as_json)
        else
          render_error("ステータス変更に失敗しました", details: format_errors(@foreshadowing))
        end
      end

      private

      def set_foreshadowing
        @foreshadowing = Foreshadowing.find_by(id: params[:id], novel_id: @novel_id)
        render_not_found unless @foreshadowing
      end

      def foreshadowing_params
        params.require(:foreshadowing).permit(
          :title, :description, :planted_episode_id,
          :resolved_episode_id, :planned_resolution_episode,
          :status, :importance
        )
      end
    end
  end
end
