class AddPaypalConfirmationToAccountBalanceTransfers < ActiveRecord::Migration
  def change
    add_column :account_balance_transfers, :confirmed_at, :datetime if ActiveRecord::Base.connection.table_exists? 'account_balance_transfers' 
  end
end
