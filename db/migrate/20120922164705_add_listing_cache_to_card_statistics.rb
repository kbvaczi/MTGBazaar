class AddListingCacheToCardStatistics < ActiveRecord::Migration
  def change
    add_column :mtg_card_statistics, :price_min,      :integer
    add_column :mtg_card_statistics, :listings_available, :integer    
    
  end
end
