# frozen_string_literal: true

module Api
  class EventsController < ::Api::ApplicationController
    def show
      @event = Event.find_by!(eid: params[:id])

      render json: {
        status: "ok",
        event: @event.nip1_hash,
        extra: {
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
        status: "error",
        error: {
          message: "Event not found"
        }
      }, status: :not_found
    end

    def create
      @event = Event.from_raw params.require(:event)
      if @event.save
        render json: {
          status: "ok",
          event: @event.nip1_hash
        }
      else
        render json: {
          status: "error",
          error: {
            message: "Event not saved",
            data: @event.errors.full_messages
          }
        }, status: :unprocessable_content
      end
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
      end

      render json: {
        status: "ok",
        returns: returns.map(&:nip1_hash),
        errored: errored
      }
    end
  end
end
