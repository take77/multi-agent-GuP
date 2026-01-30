# frozen_string_literal: true

module Api
  module V1
    class WorldSettingsController < BaseController
      before_action :set_world_setting, only: %i[show update destroy]

      # GET /api/v1/novels/:novel_id/world_settings
      def index
        scope = WorldSetting.where(novel_id: @novel_id)
        scope = scope.where(category: params[:category]) if params[:category].present?
        records, meta = paginate(scope.order(:id))
        render_success(records.as_json(except: %i[created_at updated_at]), meta: meta)
      end

      # GET /api/v1/novels/:novel_id/world_settings/:id
      def show
        render_success(@world_setting.as_json)
      end

      # POST /api/v1/novels/:novel_id/world_settings
      def create
        world_setting = WorldSetting.new(world_setting_params.merge(novel_id: @novel_id))

        if world_setting.save
          render_created(world_setting.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(world_setting))
        end
      end

      # PUT /api/v1/novels/:novel_id/world_settings/:id
      def update
        if @world_setting.update(world_setting_params)
          render_success(@world_setting.as_json)
        else
          render_error("バリデーションエラー", details: format_errors(@world_setting))
        end
      end

      # DELETE /api/v1/novels/:novel_id/world_settings/:id
      def destroy
        @world_setting.destroy!
        head :no_content
      end

      private

      def set_world_setting
        @world_setting = WorldSetting.find_by(id: params[:id], novel_id: @novel_id)
        render_not_found unless @world_setting
      end

      def world_setting_params
        params.require(:world_setting).permit(:category, :title, :description, :details)
      end
    end
  end
end
