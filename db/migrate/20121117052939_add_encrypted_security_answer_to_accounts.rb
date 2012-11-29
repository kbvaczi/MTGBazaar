class AddEncryptedSecurityAnswerToAccounts < ActiveRecord::Migration
  
  class Account < ActiveRecord::Base    # create faux model to avoid validation issues
  end
  
  def up
    add_column(   :accounts, :encrypted_security_answer, :string)    unless column_exists?(:accounts, :encrypted_security_answer)

    Account.reset_column_information   # setup faux model
    Account.all.each do |account|
      account.update_attribute(:encrypted_security_answer,     Base64.encode64(account.security_answer.encrypt(:key => "shamiggidybobbyokomoto")))
    end
    remove_column( :accounts, :security_answer)           if      column_exists?(:accounts, :security_answer)    
  end
  
  def down
    remove_column( :accounts, :encrypted_security_answer) if      column_exists?(:accounts, :encrypted_security_answer)    
    add_column(    :accounts, :security_answer, :string ) unless  column_exists?(:accounts, :security_answer)    
  end
  
end
