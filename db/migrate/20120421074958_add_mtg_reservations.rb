class AddMtgReservations < ActiveRecord::Migration
  def up
    create_table :mtg_reservations do |t|
      # foreign keys
      t.integer   :cart_id
      t.integer   :listing_id
      
      # table data
      t.integer   :quantity,          :default => 0,            :null => false

      t.timestamps
    end

    # Table Indexes
    add_index :mtg_reservations, :cart_id
    add_index :mtg_reservations, :listing_id    
  end

  def down
    drop_table :mtg_reservations
  end
end
