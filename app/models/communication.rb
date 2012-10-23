class Communication < ActiveRecord::Base
  self.table_name = 'communications'

  belongs_to  :sender,       :class_name => "User"  
  has_one     :receiver,     :class_name => "User"
  has_one     :transaction,  :class_name => "Mtg::Transaction",   :foreign_key => "mtg_transaction_id"

  #attr_accessible :message
  
  ##### ------ VALIDATIONS ----- #####

  validates_presence_of         :sender_id, :receiver_id, :message

    
  ##### ------ CALLBACKS ----- #####  
  

  
  ##### ------ PUBLIC METHODS ----- #####  


    
  ##### ------ PRIVATE METHODS ----- #####          
  protected
  
end
