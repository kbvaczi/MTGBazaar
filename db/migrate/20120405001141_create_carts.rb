class CreateCarts < ActiveRecord::Migration
  def up
    create_table :carts do |t|

      t.integer   :total_price,         :default => 0,            :null => false
      t.integer   :item_count,          :default => 0,            :null => false
      
    end

    # Table Indexes

  end

  def down
    drop_table :carts
  end
end