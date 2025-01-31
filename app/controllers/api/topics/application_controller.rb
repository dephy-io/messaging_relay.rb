# frozen_string_literal: true

module Api
  module Topics
    class ApplicationController < ::Api::ApplicationController
      before_action :set_topic

      private

      def set_topic
        if params[:topic_id].blank?
          render json: {
            status: ErrorConstants::TOPIC_NOT_FOUND
          }, status: :not_found
        end

        @topic = params[:topic_id]
      end
    end
  end
end
