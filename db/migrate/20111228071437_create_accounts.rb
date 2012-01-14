class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      
      #foreign keys
      t.integer :user_id
      
      # unprotected values which can be written from user sign-up / edit forms
      t.string  :first_name         , :default => ""          , :nil => false 
      t.string  :last_name          , :default => ""          , :nil => false 
      t.string  :country            , :default => ""          , :nil => false 
      t.string  :state              , :default => ""          , :nil => false 
      t.string  :city               , :default => ""          , :nil => false 
      t.string  :address1           , :default => ""          , :nil => false 
      t.string  :address2           , :default => ""          , :nil => false 
      t.string  :zipcode            , :default => ""          , :nil => false
      t.date    :birthdate          , :default => Time.now()  , :nil => false
      t.string  :paypal_username    , :default => ""          , :nil => false
            
      # protected values cannot be written from forms using mass assignment
      t.integer :balance            , :default => 0
      t.integer :number_sales       , :default => 0
      t.integer :number_purchases   , :default => 0
      t.float   :average_rating     , :default => 0
      t.float   :average_ship_time  , :default => 0                             #number of days average from purchase to shipping
      t.boolean :vacation           , :default => false                         #unlist sales when vacation is turned on

      t.timestamps
      
    end
    
    # Table Indexes
    
  end

  def self.down
    drop_table :accounts
  end
end
