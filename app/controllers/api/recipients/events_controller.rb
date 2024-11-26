# frozen_string_literal: true

module Api::Recipients
  class EventsController < ::Api::Recipients::ApplicationController
    def index
      @pagy, @records = pagy_uuid_cursor(
        Event.of_recipient(@recipient),
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
      @event = Event.of_recipient(@recipient).order(id: :desc).first

      render json: {
        status: "ok",
        event: @event&.nip1_hash
      }
    end
  end
end
