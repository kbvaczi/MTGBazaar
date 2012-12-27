class AddShippingOptions < ActiveRecord::Migration
  
  class Mtg::Order < ActiveRecord::Base    # create faux model to avoid validation issues
  end

  class Mtg::Transaction < ActiveRecord::Base    # create faux model to avoid validation issues
  end  
  
  def up
=begin    # add signature confirmation and insurance booleans to shipping label.  Price will be captured in total price & in raw response from stamps
    # add_column(:mtg_transactions_shipping_labels, :insurance,              :boolean, :default => false)    unless column_exists?(:mtg_transactions_shipping_labels, :insurance)
    # add_column(:mtg_transactions_shipping_labels, :signature_confirmation, :boolean, :default => false)    unless column_exists?(:mtg_transactions_shipping_labels, :signature_confirmation)
    
    # track the costs in each order so that we can correctly show cart and checkout
    # add_column(:mtg_orders, :insurance_cost,              :integer, :default => 0)      unless column_exists?(:mtg_orders, :insurance)
    # add_column(:mtg_orders, :signature_confirmation_cost, :integer, :default => 0)      unless column_exists?(:mtg_orders, :signature_confirmation_cost)

    # 'usps' or "pickup"
    # add_column(:mtg_orders, :shipping_type,               :string,  :default => 'usps') unless column_exists?(:mtg_orders, :shipping_type)    
=end
    unless column_exists? :mtg_transactions, :shipping_options
      add_column(:mtg_transactions, :shipping_options, :text) 
    end 
                                                                                           
    unless column_exists? :mtg_orders, :shipping_options
      add_column(:mtg_orders, :shipping_options, :text)
    end

    # set defaults for existing orders
    Mtg::Order.reset_column_information   # setup faux model
    Mtg::Order.scoped.each do |order|
      order.update_attribute(:shipping_options, {:shipping_type    => 'usps',
                                                 :shipping_charges => {:basic_shipping => order.shipping_cost}})
    end

    Mtg::Transaction.reset_column_information   # setup faux model
    Mtg::Transaction.scoped.each do |transaction|
      transaction.update_attribute(:shipping_options, {:shipping_type    => 'usps',
                                                       :shipping_charges => {:basic_shipping => transaction.shipping_cost}})
    end    
    
  end

  def down
=begin
    remove_column(:mtg_transactions_shipping_labels, :insurance)                if column_exists?(:mtg_transactions_shipping_labels, :insurance)                    
    remove_column(:mtg_transactions_shipping_labels, :signature_confirmation)   if column_exists?(:mtg_transactions_shipping_labels, :signature_confirmation)                          
    
    remove_column(:mtg_orders, :insurance_cost)                if column_exists?(:mtg_orders, :insurance_cost)
    remove_column(:mtg_orders, :signature_confirmation_cost)   if column_exists?(:mtg_orders, :signature_confirmation_cost)
    
    remove_column(:mtg_orders, :shipping_type)                 if column_exists?(:mtg_orders, :shipping_type)
=end 

    remove_column(:mtg_orders,       :shipping_options) if column_exists?(:mtg_orders,       :shipping_options)
    remove_column(:mtg_transactions, :shipping_options) if column_exists?(:mtg_transactions, :shipping_options)                        
  end

end
