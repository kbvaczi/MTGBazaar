# encoding: UTF-8
ActiveAdmin.register Mtg::Transaction do
  #menu :label => "Transactions", :parent => "MTG"
  #extend Mtg::CardsHelper   # access mtg_card helpers inside this class

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
  
  # ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true
  scope :pending do |transaction|
    transaction.where(:status => "pending")
  end
  scope :rejected do |transaction|
    transaction.where(:status => "rejected")
  end
  scope :confirmed do |transaction|
    transaction.where(:status => "confirmed")
  end  
  scope :shipped do |transaction|
    transaction.where(:status => "shipped")
  end
  scope :delivered do |transaction|
    transaction.where(:status => "delivered")
  end
  scope :final do |transaction|
    transaction.where(:status => "final")
  end
  
  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |t|
      link_to t.id, admin_mtg_transaction_path(t)
    end
    column :seller
    column :buyer
    column "Listings", :sortable => false do |transaction|
       link_to transaction.listings.count, admin_mtg_listings_path("q[transaction_id_eq]" => transaction.id)
    end
    column :total_value, :sortable => false do |transaction|
      number_to_currency(transaction.total_value)
    end
    column "Status", :sortable => :status do |transaction|
      transaction.status
    end
    column :buyer_confirmed_at
    column :seller_rejected_at
    column :rejection_reason    
    column :seller_confirmed_at    
    column :seller_shipped_at
    column :seller_delivered_at    
    column :seller_rating
    column :buyer_feedback  
    column :created_at
    column :updated_at    
  end
  
  # ------ FILTERS FOR INDEX ------- #
  filter :seller, :as => :select, :input_html => {:class => "chzn-select"}    
  filter :buyer, :as => :select, :input_html => {:class => "chzn-select"}      
  filter :status, :as => :select, :collection => ["pending","confirmed","shipped","delivered","final"], :input_html => {:class => "chzn-select"}      
  filter :buyer_confirmed_at
  filter :seller_rejected_at
  filter :rejection_reason    
  filter :seller_confirmed_at    
  filter :seller_shipped_at
  filter :seller_delivered_at    
  filter :seller_rating, :as => :select, :collection => ["1","2","3","4","5"], :input_html => {:class => "chzn-select"}      
  filter :buyer_feedback
  filter :created_at
  filter :updated_at
  filter :sold_at  


end
