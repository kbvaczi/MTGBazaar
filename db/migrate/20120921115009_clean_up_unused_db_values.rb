class CleanUpUnusedDbValues < ActiveRecord::Migration
  def up
    remove_column( :mtg_listings, :sold_at)    if column_exists?(:mtg_listings, :sold_at)# listings are no longer sold
    remove_column(:mtg_listings, :rejected_at) if column_exists?(:mtg_listings, :rejected_at)# listings are no longer sold

    remove_index(:mtg_listings, :cart_id)      if index_exists?(:mtg_listings, :cart_id)    
    remove_column(:mtg_listings, :cart_id)     if column_exists?(:mtg_listings, :cart_id)# this is handled through reservations now
    
    remove_index  :mtg_listings, :transaction_id
    remove_column :mtg_listings, :transaction_id # transaction ids are no longer in listings.  created transaction items         
    
    remove_column :mtg_transactions, :buyer_delivery_confirmation # this is handled through datetime buyer_confirmed_at
    
    remove_column :accounts, :number_purchases # this is handled through user statistics
    remove_column :accounts, :number_sales # user statistics
    remove_column :accounts, :average_rating # user statistics        
    remove_column :accounts, :average_ship_time # user statistics            

    add_index     :mtg_listings,  :language
    add_index     :mtg_listings,  :foil
    add_index     :mtg_listings,  :misprint
    add_index     :mtg_listings,  :signed
    add_index     :mtg_listings,  :altart
    
  end
end
