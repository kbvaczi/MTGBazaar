class AddApprovedAtToAccountBalanceTransfer < ActiveRecord::Migration
  def change
    add_column :account_balance_transfers, :approved_at,    :datetime
    add_column :account_balance_transfers, :transfer_type,  :string    
  end
end
