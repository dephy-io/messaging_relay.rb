# frozen_string_literal: true

module Api
  module Recipients
    class ApplicationController < ::Api::ApplicationController
      before_action :set_recipient

      private

      def set_recipient
        if params[:recipient_id].blank?
          render json: {
            status: ErrorConstants::RECIPIENT_NOT_FOUND
          }, status: :not_found
        end

        @recipient = params[:recipient_id]
      end
    end
  end
end
