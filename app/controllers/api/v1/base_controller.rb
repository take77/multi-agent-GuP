# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_novel

      private

      def set_novel
        # 第1中隊の認証基盤・Novelモデルが揃い次第、正式な認証・認可チェックに置き換え
        @novel_id = params[:novel_id].to_i
        # TODO: 認証ユーザーが所有する小説かチェック
        # @novel = current_user.novels.find(params[:novel_id])
      end

      def render_success(data, status: :ok, meta: {})
        body = { success: true, data: data }
        body[:meta] = meta if meta.present?
        render json: body, status: status
      end

      def render_created(data)
        render_success(data, status: :created)
      end

      def render_error(message, status: :unprocessable_entity, details: [])
        body = {
          success: false,
          error: {
            code: error_code_for(status),
            message: message
          }
        }
        body[:error][:details] = details if details.present?
        render json: body, status: status
      end

      def render_not_found
        render_error("リソースが見つかりません", status: :not_found)
      end

      def paginate(scope)
        page = (params[:page] || 1).to_i
        per_page = [(params[:per_page] || 20).to_i, 100].min

        records = scope.offset((page - 1) * per_page).limit(per_page)
        total = scope.count

        [records, { total: total, page: page, per_page: per_page }]
      end

      def error_code_for(status)
        case status
        when :bad_request then "BAD_REQUEST"
        when :unauthorized then "UNAUTHORIZED"
        when :forbidden then "FORBIDDEN"
        when :not_found then "NOT_FOUND"
        when :unprocessable_entity then "VALIDATION_ERROR"
        else "INTERNAL_ERROR"
        end
      end

      def format_errors(record)
        record.errors.map { |e| { field: e.attribute, message: e.full_message } }
      end
    end
  end
end
