# frozen_string_literal: true

module Api
  class ApplicationController < ActionController::API
    include Pagy::Backends::UuidCursor

    module ErrorConstants
      OK = "ok"
      INVALID_JSON = "invalid_json"
      EVENT_NOT_FOUND = "event_not_found"
      RECIPIENT_NOT_FOUND = "recipient_not_found"
      TOPIC_NOT_FOUND = "topic_not_found"
      BAD_EVENT = "bad_event"
      POST_TOO_FAST = "post_too_fast"
    end

    rescue_from JSON::ParserError do
      render json: {
        status: ErrorConstants::INVALID_JSON
      }, status: :bad_request
    end
  end
end
