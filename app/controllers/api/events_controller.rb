# frozen_string_literal: true

module Api
  class EventsController < ::Api::ApplicationController
    def index
      @pagy, @records = pagy_uuid_cursor(
        Event.all,
        after: params[:after], primary_key: :eid, order: { id: :asc }
      )

      render json: {
        status: ErrorConstants::OK,
        events: @records.map(&:nip1_hash),
        pagination: {
          has_more: @pagy.has_more?
        }
      }
    end

    def show
      @event = Event.find_by!(eid: params[:id])

      render json: {
        status: ErrorConstants::OK,
        event: @event.nip1_hash,
        metadata: {
          topic: @event.topic,
          session: @event.session,
          latest: {
            id: @event.latest.eid,
            created_at: @event.latest.created_at.to_i
          },
          root_hash: @event.merkle_tree_root.calculated_hash,
          inclusion_proof: @event.inclusion_proof
        }
      }
    rescue ActiveRecord::RecordNotFound => _ex
      render json: {
        status: ErrorConstants::EVENT_NOT_FOUND
      }, status: :not_found
    end

    def create
      @event = Event.from_raw params.require(:event)
      if @event.save
        render json: {
          status: ErrorConstants::OK,
          event: @event.nip1_hash
        }
      else
        render json: {
          status: ErrorConstants::BAD_EVENT,
          error: {
            data: @event.errors.full_messages
          }
        }, status: :unprocessable_content
      end
    rescue ActiveRecord::StaleObjectError
      render json: {
        status: ErrorConstants::POST_TOO_FAST
      }, status: :unprocessable_content
    end

    def batch_create
      returns = []
      errored = nil

      params.require(:events).map do |event_params|
        event_params.permit!

        event = Event.from_raw(event_params)
        if event.save
          returns << event
        else
          errored = event_params
          break
        end
      rescue ActiveRecord::StaleObjectError
        errored = event_params
      end

      render json: {
        status: ErrorConstants::OK,
        saved: returns.map(&:nip1_hash),
        errored: errored
      }
    end
  end
end
