class CreateTransactions < ActiveRecord::Migration
  def up
    create_table :transactions do |t|
      t.integer :test1_id
      t.integer :test2_id      
      t.timestamps
    end
  end
  def down
    drop_table :transactions
  end
end
