class CleanUpUnusedDbValues < ActiveRecord::Migration
  def up
    remove_column :mtg_listings, :sold_at # listings are no longer sold
    remove_column :mtg_listings, :rejected_at # listings are no longer sold    
    remove_column :mtg_listings, :cart_id # this is handled through reservations now
    
    remove_index  :mtg_listings, :transaction_id
    remove_column :mtg_listings, :transaction_id # transaction ids are no longer in listings.  created transaction items         
    
    remove_column :mtg_transactions, :buyer_delivery_confirmation # this is handled through datetime buyer_confirmed_at
    
    remove_column :accounts, :number_purchases # this is handled through user statistics
    remove_column :accounts, :number_sales # user statistics
    remove_column :accounts, :average_rating # user statistics        
    remove_column :accounts, :average_ship_time # user statistics            
    
    
    
  end
end
