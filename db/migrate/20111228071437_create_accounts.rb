class CreateAccounts < ActiveRecord::Migration
  def self.up
  
    create_table :accounts do |t|
      
      #foreign keys
      t.integer :user_id
      
      # unprotected values which can be written from user sign-up / edit forms
      t.string  :first_name         , :default => ""          , :null => false 
      t.string  :last_name          , :default => ""          , :null => false 
      t.string  :country            , :default => ""          , :null => false 
      t.string  :state              , :default => ""          , :null => false 
      t.string  :city               , :default => ""          , :null => false 
      t.string  :address1           , :default => ""          , :null => false 
      t.string  :address2           , :default => ""          , :null => false 
      t.string  :zipcode            , :default => ""          , :null => false
      t.date    :birthdate          , :default => Time.now()  , :null => false
      t.string  :paypal_username    , :default => ""          , :null => false
      t.string  :security_question  , :default => ""          , :null => false
      t.string  :security_answer    , :default => ""          , :null => false
            
      # protected values cannot be written from forms using mass assignment
      t.integer :balance            , :default => 0           , :null => false
      t.integer :number_sales       , :default => 0           , :null => false
      t.integer :number_purchases   , :default => 0           , :null => false
      t.float   :average_rating     , :default => 0           , :null => false
      t.float   :average_ship_time  , :default => 0           , :null => false         # number of days average from purchase to shipping
      t.boolean :vacation           , :default => false       , :null => false         # unlist sales when vacation is turned on

      t.timestamps
      
    end
    
    # Table Indexes
    add_index :accounts, :user_id
    
  end

  def self.down
    drop_table :accounts
  end
  
end
