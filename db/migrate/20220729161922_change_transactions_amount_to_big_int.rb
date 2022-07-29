class ChangeTransactionsAmountToBigInt < ActiveRecord::Migration[7.0]
  def change
    change_column :transactions, :amount_in_cents, :bigint
  end
end
