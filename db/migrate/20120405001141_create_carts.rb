class CreateCarts < ActiveRecord::Migration
  def up
    create_table :carts do |t|
      # foreign keys
      t.integer   :user_id
      
      # table data
      t.integer   :total_price,         :default => 0,            :null => false
      t.integer   :item_count,          :default => 0,            :null => false

      t.timestamps
    end

    # Table Indexes
    add_index :carts, :user_id
  end

  def down
    drop_table :carts
  end
end