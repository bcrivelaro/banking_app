class ChangeAccountsBalanceToBigInt < ActiveRecord::Migration[7.0]
  def change
    change_column :accounts, :balance_in_cents, :bigint
  end
end
