class CreateAccountBalanceTransfers < ActiveRecord::Migration
  def up
    create_table :account_balance_transfers do |t|
      #foreign keys
      t.integer :account_id

      # unprotected values which can be written from user sign-up / edit forms
      t.integer :balance            , :default => 0           , :null => false
      t.string  :current_sign_in_ip , :default => ""          , :null => false
      
      # protected values cannot be written from forms using mass assignment
      # none
      
      t.timestamps
    end
    
    # Table Indexes
    add_index :account_balance_transfers, :account_id
  end
  
  def down
    drop_table :account_balance_transfers
  end
end
