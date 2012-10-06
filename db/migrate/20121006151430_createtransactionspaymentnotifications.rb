class Createtransactionspaymentnotifications < ActiveRecord::Migration
  def up
    drop_table    :payment_notifications        if ActiveRecord::Base.connection.table_exists? 'payment_notifications'        
    
    create_table  :mtg_transactions_payment_notifications do |t|
      #foreign keys      
      t.integer   :payment_id

      #table data
      t.text      :response
      t.string    :status
      t.string    :paypal_transaction_id

      t.timestamps      
    end
    
    add_index     :mtg_transactions_payment_notifications, :payment_id
  end
  
  def down
    drop_table    :mtg_transactions_payment_notifications
  end
  
end
