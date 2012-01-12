class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      
      #foreign keys
      t.integer :user_id
      
      
      # unprotected values
      t.string  :first_name
      t.string  :last_name
      t.string  :country
      t.string  :state
      t.string  :city
      t.string  :address1
      t.string  :address2
      t.string  :zipcode
      t.date    :birthdate
      t.string  :paypal_username    
            
      # protected values
      t.integer :balance            , :default => 0
      t.integer :number_sales       , :default => 0
      t.float   :average_rating     , :default => 0
      t.boolean :vacation           , :default => false

      t.timestamps
      
    end
  end

  def self.down
    drop_table :accounts
  end
end
