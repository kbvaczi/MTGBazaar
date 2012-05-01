class CreateMtgTransactions < ActiveRecord::Migration
  def up
    create_table :mtg_transactions do |t|
      #foreign keys
      t.integer   :buyer_id
      t.integer   :seller_id

      t.datetime  :buyer_confirmed_at
      t.datetime  :seller_confirmed_at
      
      t.datetime  :seller_rejected_at
      t.string    :rejection_reason,              :default => ""
      t.string    :rejection_message,             :default => ""
      
      t.datetime  :seller_shipped_at
      t.string    :seller_tracking_number,        :default => ""
      
      t.datetime  :seller_delivered_at
      t.boolean   :buyer_delivery_confirmation,   :default => nil        
      #t.string    :delivery_problem,              :default => ""         #"condition" condition not right, "content" content not right
      #t.string    :delivery_problem_text,         :default => ""
      
      t.string    :buyer_feedback,                :default => "P"         #Positive "P", Negative "N"
      t.string    :buyer_feedback_text,           :default => ""

      t.string    :status,                        :default => "pending"                              # final, rejected?

      t.timestamps
    end

    # Table Indexes
    add_index :mtg_transactions, :buyer_id
    add_index :mtg_transactions, :seller_id
    add_index :mtg_transactions, :status 

  end

  def down
    drop_table :mtg_transactions    
  end
end