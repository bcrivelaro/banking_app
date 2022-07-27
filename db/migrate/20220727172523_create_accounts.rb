# frozen_string_literal: true

class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :account_number, null: false
      t.integer :balance_in_cents, null: false, default: 0

      t.timestamps
    end

    add_index :accounts, :account_number, unique: true
  end
end
