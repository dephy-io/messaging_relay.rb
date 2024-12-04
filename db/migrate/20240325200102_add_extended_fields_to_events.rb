# frozen_string_literal: true

class AddExtendedFieldsToEvents < ActiveRecord::Migration[8.0]
  def change
    change_table :events do |t|
      t.string :session, null: false

      t.string :topic, null: true, index: true
      t.string :recipient, null: true, index: true

      t.index %i[pubkey session]
    end
  end
end
