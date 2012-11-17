class AddEncryptedSecurityAnswerToAccounts < ActiveRecord::Migration
  
  class Account < ActiveRecord::Base
  end
  
  def up
    add_column(   :accounts, :encrypted_security_answer, :string )    unless column_exists?(:accounts, :encrypted_security_answer)

    Account.reset_column_information   # setup faux model
    Account.all.each do |account|
      account.update_attribute(:security_answer, account.attributes_before_type_cast["security_answer"])
    end
    remove_column( :accounts, :security_answer)           if      column_exists?(:accounts, :security_answer)    
  end
  
  def down
    remove_column( :accounts, :encrypted_security_answer) if      column_exists?(:accounts, :encrypted_security_answer)    
    add_column(    :accounts, :security_answer, :string ) unless  column_exists?(:accounts, :security_answer)    
  end
  
end
