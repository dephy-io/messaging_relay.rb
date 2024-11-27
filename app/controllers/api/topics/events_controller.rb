# frozen_string_literal: true

module Api::Topics
  class EventsController < ::Api::Topics::ApplicationController
    def index
      @pagy, @records = pagy_uuid_cursor(
        Event.of_topic(@topic),
        after: params[:after], primary_key: :eid, order: { id: :asc }
      )

      render json: {
        status: "ok",
        events: @records.map(&:nip1_hash),
        pagination: {
          has_more: @pagy.has_more?
        }
      }
    end

    def latest
      @event = Event.of_topic(@topic).order(id: :desc).first

      render json: {
        status: "ok",
        event: @event&.nip1_hash
      }
    end
  end
end
