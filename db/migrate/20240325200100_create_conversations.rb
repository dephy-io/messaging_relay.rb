# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations, primary_key: %i[pubkey session] do |t|
      t.string :pubkey, null: false
      t.string :session, null: false

      t.integer :lock_version
      t.datetime :latest_event_created_at
      t.integer :events_count

      t.timestamps
    end
  end
end