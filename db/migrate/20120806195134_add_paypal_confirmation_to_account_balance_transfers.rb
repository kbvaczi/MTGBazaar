class AddPaypalConfirmationToAccountBalanceTransfers < ActiveRecord::Migration
  def change
    add_column :account_balance_transfers, :confirmed_at, :datetime
  end
end
