class Mtg::Transactions::Feedback < ActiveRecord::Base
  self.table_name = 'mtg_transactions_feedback'    
  
  belongs_to :transaction,  :class_name => "Mtg::Transaction",  :foreign_key => "transaction_id"

  # validations
  validates_presence_of :transaction, :rating
  
  def display_rating
    case self.rating
      when "1"
        "Positive"
      when "-1"
        "Negative"
      when "0"
        "Neutral"
    end
  end
  
end