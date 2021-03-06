class CreateMtgCardStatistics < ActiveRecord::Migration
  def up
    create_table :mtg_card_statistics do |t|
      # foreign keys
      t.integer   :card_id

      # class variables  
      t.integer   :number_sales,              :default => 0
      t.integer   :price_low
      t.integer   :price_med
      t.integer   :price_high
      
      t.timestamps
    end

    # Table Indexes
    add_index :mtg_card_statistics, :card_id
    
    Mtg::Card.all.each do |card|
      card.statistics = Mtg::Cards::Statistics.create
    end
  end

  def down
    drop_table :mtg_card_statistics
  end
end
