class CreatePaymentNotifications < ActiveRecord::Migration
  def up
    create_table :payment_notifications do |t|
      t.text :params
      t.string :status
      t.string :transaction_id
      t.integer :account_balance_transfer_id

      t.timestamps
    end
  end
  
  def down
    drop_table :payment_notifications if ActiveRecord::Base.connection.table_exists? 'payment_notifications' 
  end
end
