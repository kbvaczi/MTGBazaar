class AddListingCacheToCardStatistics < ActiveRecord::Migration
  def change
    add_column :mtg_card_statistics, :price_min,          :integer,           :default => 0
    add_column :mtg_card_statistics, :listings_available, :integer,           :default => 0    
  end
end
