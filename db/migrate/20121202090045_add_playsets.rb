class AddPlaysets < ActiveRecord::Migration

  class Mtg::Reservation < ActiveRecord::Base    # create faux model to avoid validation issues
  end
  
  class Mtg::Order < ActiveRecord::Base    # create faux model to avoid validation issues
  end  

  class Mtg::Transactions::Item < ActiveRecord::Base    # create faux model to avoid validation issues
  end  
  
  def up
    add_column(:mtg_listings,           :number_cards_per_item,     :integer, :default => 1)     unless column_exists?(:mtg_listings,          :number_cards_per_item)
    add_column(:mtg_listings,           :playset,                   :boolean, :default => false) unless column_exists?(:mtg_listings,          :playset)    

    add_column(:mtg_transaction_items,  :number_cards_per_item,     :integer, :default => 1)     unless column_exists?(:mtg_transaction_items, :number_cards_per_item)                
    add_column(:mtg_transaction_items,  :playset,                   :boolean, :default => false) unless column_exists?(:mtg_transaction_items, :playset)

    add_column(:mtg_reservations,       :cards_quantity,            :integer)                    unless column_exists?(:mtg_reservations,      :cards_quantity)        
    add_column(:mtg_orders,             :cards_quantity,            :integer)                    unless column_exists?(:mtg_orders,            :cards_quantity)            
    add_column(:mtg_transactions,       :cards_quantity,            :integer)                    unless column_exists?(:mtg_transactions,      :cards_quantity)                
    
    Mtg::Reservation.reset_column_information   # setup faux model
    Mtg::Reservation.scoped.each do |res|
      res.update_attribute(:cards_quantity, res.quantity)
    end
    
    Mtg::Order.reset_column_information   # setup faux model
    Mtg::Order.scoped.each do |order|
      order.update_attribute(:cards_quantity, order.item_count)
    end
    
=begin    
    Mtg::Transactions::Item.reset_column_information   # setup faux model
    Mtg::Transactions::Item.scoped.each do |item|
      item.update_attribute(:number_cards_per_item, 1)
    end
=end
    
  end
  
  def down
    remove_column(:mtg_listings,          :number_cards_per_item)     if column_exists?(:mtg_listings,          :number_cards_per_item)
    remove_column(:mtg_listings,          :playset)                   if column_exists?(:mtg_listings,          :playset)    
             
    remove_column(:mtg_transaction_items, :number_cards_per_item)     if column_exists?(:mtg_transaction_items, :number_cards_per_item)                
    remove_column(:mtg_transaction_items, :playset)                   if column_exists?(:mtg_transaction_items, :playset)    
    
    remove_column(:mtg_reservations,      :cards_quantity)            if column_exists?(:mtg_reservations,      :cards_quantity)        
    remove_column(:mtg_orders,            :cards_quantity)            if column_exists?(:mtg_orders,            :cards_quantity)                
    remove_column(:mtg_transactions,      :cards_quantity)            if column_exists?(:mtg_transactions,      :cards_quantity)                    
  end
  
end
