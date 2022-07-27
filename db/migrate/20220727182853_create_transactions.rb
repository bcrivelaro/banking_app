class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions, id: :uuid do |t|
      t.string :transaction_type, null: false
      t.references :from_account, foreign_key: { to_table: :accounts }, type: :uuid
      t.references :to_account, null: false, foreign_key: { to_table: :accounts }, type: :uuid
      t.integer :amount_in_cents, null: false

      t.timestamps
    end
  end
end
