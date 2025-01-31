# frozen_string_literal: true

module Api
  class HomeController < Api::ApplicationController
    def index
      render json: {
        status: ErrorConstants::OK
      }
    end
  end
end
