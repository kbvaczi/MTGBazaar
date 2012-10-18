class CreateTransactionFeedback < ActiveRecord::Migration
  def up 
    create_table  :mtg_transactions_feedback do |t|
      #foreign keys      
      t.integer   :transaction_id

      #table data
      t.string    :rating
      t.string    :comment
      t.string    :seller_response_comment

      t.timestamps      
    end
  
    add_index     :mtg_transactions_feedback, :transaction_id
  end
  
  def down
    drop_table    :mtg_transactions_feedback
  end
end
