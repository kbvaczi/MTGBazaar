class AddQuantityAvailableToTransactions::Items < ActiveRecord::Migration
  # Create a Faux class so that validations are not run when model is updated... prevents migration conflicts
  class Mtg::Transactions::Item < ActiveRecord::Base
  end
  
  def up
    add_column :mtg_transaction_items, :quantity_available, :integer
    add_column :mtg_transaction_items, :quantity_requested, :integer
    Mtg::Transactions::Item.reset_column_information   # setup faux model
    Mtg::Transactions::Item.all.each do |i|
      i.update_attributes!(:quantity_available => i.quantity, :quantity_requested => i.quantity)
    end
    remove_column :mtg_transaction_items, :quantity
  end
  
  def down
    add_column :mtg_transaction_items, :quantity, :integer
    Mtg::Transactions::Item.reset_column_information   # setup faux model
    Mtg::Transactions::Item.all.each do |i|
      i.update_attribute(:quantity, i.quantity_available)
    end
    remove_column :mtg_transaction_items, :quantity_available
    remove_column :mtg_transaction_items, :quantity_requested
  end

end
