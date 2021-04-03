# frozen_string_literal: true

class CreateUrl < ActiveRecord::Migration[6.0]
  def change
    create_table :urls do |t|
      t.text :url, null: false, index: true
      t.string :shortcode, null: false
      t.datetime :last_seen_date
      t.integer :redirect_count, default: 0

      t.index(:shortcode, unique: true)

      t.timestamps
    end
  end
end
