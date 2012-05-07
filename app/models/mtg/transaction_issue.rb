class Mtg::TransactionIssue < ActiveRecord::Base
# ---------------- MODEL SETUP ----------------
  
  self.table_name = 'mtg_transaction_issues'
  
  belongs_to :author,       :class_name => "User"
  belongs_to :transaction,  :class_name => "Mtg::Transaction"
  
# ---------------- VALIDATIONS ----------------   
   
  validates_presence_of   :problem, :description, :transaction_id, :author_id
  validates               :description,               :length => {:maximum => 500}
  
# ---------------- MEMBER METHODS -------------
  
  
# ---------------- MISC METHODS ---------------  
  
end