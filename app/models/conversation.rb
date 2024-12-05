# frozen_string_literal: true

class Conversation < ApplicationRecord
  self.primary_key = %i[pubkey session]
  self.lock_optimistically = true

  has_many :events,
           foreign_key: %i[pubkey session],
           dependent: :restrict_with_exception

  def latest_event
    if latest_eid.blank?
      nil
    else
      Event.find(latest_eid)
    end
  end
end
