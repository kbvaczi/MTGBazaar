class AddAddressVerificationToAccounts < ActiveRecord::Migration
  def up
    add_column :accounts, :address_verification, :string
  end
  
  def down
    remove_column :accounts, :address_verification
  end
end
