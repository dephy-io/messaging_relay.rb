# frozen_string_literal: true

class Conversation < ApplicationRecord
  self.primary_key = %i[pubkey session]
  self.lock_optimistically = true

  has_many :events,
           foreign_key: %i[pubkey session],
           counter_cache: :events_count,
           dependent: :restrict_with_exception
end
