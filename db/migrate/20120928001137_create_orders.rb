class CreateOrders < ActiveRecord::Migration
  def change
    create_table :mtg_orders do |t|
      
      #foreign keys(none)      
      t.integer   :cart_id
      t.integer   :seller_id
      
      #table data
      t.integer   :item_count
      t.integer   :item_price_total 
      t.integer   :shipping_cost
      t.integer   :total_cost
    
      t.timestamps
      
    end

    #indexes
    add_index :mtg_orders, :cart_id
    add_index :mtg_orders, :seller_id
    
    add_column :mtg_reservations, :order_id, :integer
    add_index  :mtg_reservations, :order_id

    remove_index  :mtg_reservations, :cart_id
    remove_column :mtg_reservations, :cart_id
  
  end
end
