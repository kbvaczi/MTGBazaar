class AddApprovedAtToAccountBalanceTransfer < ActiveRecord::Migration
  def up
    add_column :account_balance_transfers, :approved_at,    :datetime
    add_column :account_balance_transfers, :transfer_type,  :string    
  end
  
  def down
    remove_column :account_balance_transfers, :approved_at   if ActiveRecord::Base.connection.table_exists? 'account_balance_transfers' 
    remove_column :account_balance_transfers, :transfer_type if ActiveRecord::Base.connection.table_exists? 'account_balance_transfers'     
  end
end
