class Mtg::Transaction < ActiveRecord::Base
  self.table_name = 'mtg_transactions'
  
  belongs_to :seller,   :class_name => "User"
  belongs_to :buyer,    :class_name => "User"  
  has_many :listings, :class_name => "Mtg::Listing", :foreign_key => "transaction_id"
  
  
    
end
