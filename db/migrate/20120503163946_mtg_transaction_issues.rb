class  CreateMtgTransactionIssues < ActiveRecord::Migration
  def up
    create_table :mtg_transaction_issues do |t|
      #foreign keys
      t.integer   :transaction_id
      t.integer   :author_id
 
      t.string    :problem,              :default => ""         #"d-condition" items delivered condition not right, "d-content" items delivered content not right, "nd" package not delivered 
      t.string    :description,          :default => ""

      t.string    :status,               :default => "new"                              # new, 

      t.timestamps
    end

    # Table Indexes
    add_index :mtg_transaction_issues, :transaction_id
    add_index :mtg_transaction_issues, :author_id      
  end

  def down
    drop_table :mtg_transaction_issues    
  end
end