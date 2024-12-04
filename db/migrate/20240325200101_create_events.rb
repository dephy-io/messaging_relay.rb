# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :eid, null: false, index: { unique: true }
      t.string :pubkey, null: false, index: true
      t.integer :kind, null: false
      t.jsonb :tags, array: true, default: []
      t.string :content, null: false
      t.string :sig, null: false

      t.datetime :created_at, null: false, index: true
    end
  end
end
