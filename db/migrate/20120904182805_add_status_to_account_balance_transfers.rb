class AddStatusToAccountBalanceTransfers < ActiveRecord::Migration
  def up
    add_column :account_balance_transfers, :status, :string, :default => "pending"
    
    AccountBalanceTransfer.all.each do |transfer|
      if transfer.confirmed_at
        transfer.update_attribute(:status, "completed")
      elsif transfer.transfer_type == "deposit" && transfer.updated_at < 1.days.ago
        transfer.update_attribute(:status, "cancelled")
      else
        transfer.update_attribute(:status, "pending")
      end
    end
    
  end
  
  def down
    remove_column :account_balance_transfers, :status
  end

end
