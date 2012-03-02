class CreateUsersDeposits < ActiveRecord::Migration
  def change
    create_table :users_deposits do |t|
      #foreign keys
      t.integer :account_id

      # unprotected values which can be written from user sign-up / edit forms
      # none
      
      # protected values cannot be written from forms using mass assignment
      t.integer :balance            , :default => 0           , :null => false
      t.string  :current_sign_in_ip , :default => ""          , :null => false       
      t.timestamps
    end
    # Table Indexes
    add_index :users_deposits, :account_id
  end
end
