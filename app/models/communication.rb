class Communication < ActiveRecord::Base
  self.table_name = 'communications'

  belongs_to  :sender,       :polymorphic => true # can be either class "User" or "AdminUser"
  belongs_to  :receiver,     :class_name => "User"
  belongs_to  :transaction,  :class_name => "Mtg::Transaction",   :foreign_key => "mtg_transaction_id"

  #attr_accessible :message
  
  ##### ------ VALIDATIONS ----- #####

  validates_presence_of         :sender_id, :sender_type, :receiver_id
  validates                     :message,  :length => { :minimum => 1, :maximum => 500 }

    
  ##### ------ CALLBACKS ----- #####  
  
  ##### ------ SCOPES ----- #####  
  
  def self.unread
    where("communications.unread = ?", true)
  end
  
  ##### ------ PUBLIC METHODS ----- #####  


    
  ##### ------ PRIVATE METHODS ----- #####          
  protected
  
end
