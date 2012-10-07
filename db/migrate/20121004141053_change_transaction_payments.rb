class ChangeTransactionPayments < ActiveRecord::Migration
  def up
    add_column   (:mtg_transaction_payments,   :paypal_paykey,                   :string)  unless column_exists?(:mtg_transaction_payments, :paypal_paykey)
    add_column   (:mtg_transaction_payments,   :paypal_transaction_number,       :string)  unless column_exists?(:mtg_transaction_payments, :paypal_transaction_number)
    add_column   (:mtg_transaction_payments,   :paypal_purchase_response,        :text)    unless column_exists?(:mtg_transaction_payments, :paypal_purchase_response)
    remove_column :mtg_transaction_payments,   :status
    add_column    :mtg_transaction_payments,   :status,                          :string,         :default => "unpaid"
    remove_column :mtg_transaction_payments,   :price    
    add_column    :mtg_transaction_payments,   :amount,                          :integer,        :default => 0
    add_column    :mtg_transaction_payments,   :commission,                      :integer,        :default => 0  
    add_column    :mtg_transaction_payments,   :shipping_cost,                   :integer,        :default => 0           
    add_column    :mtg_transaction_payments,   :commission_rate,                 :float,          :default => 0.0

    
    drop_table    :account_balance_transfers      if ActiveRecord::Base.connection.table_exists? 'account_balance_transfers'
    drop_table    :mtg_transaction_credits        if ActiveRecord::Base.connection.table_exists? 'mtg_transaction_credits'    

    add_column    :accounts,                   :commission_rate,                 :float,          :default => nil
    add_column    :mtg_transactions,           :order_id,                        :integer
    add_index     :mtg_transactions,           :order_id
  end
  
  def down
    add_column       :mtg_transaction_payments,   :price,                           :integer    
    remove_column    :mtg_transaction_payments,   :shipping_cost 
    remove_column    :mtg_transaction_payments,   :paypal_paykey
    remove_column    :mtg_transaction_payments,   :paypal_transaction_number
    remove_column    :mtg_transaction_payments,   :paypal_purchase_response
    remove_column    :mtg_transaction_payments,   :amount
    remove_column    :mtg_transaction_payments,   :commission
    remove_column    :mtg_transaction_payments,   :commission_rate

    remove_column    :accounts,                   :commission_rate  
    remove_column    :mtg_transactions,           :order_id        
  end  

end
