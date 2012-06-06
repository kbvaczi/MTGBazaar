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
  scope :confirmed do |transaction|
    transaction.where(:status => "confirmed")
  end  
  scope :shipped do |transaction|
    transaction.where(:status => "shipped")
  end
  scope :final do |transaction|
    transaction.where(:status => "completed")
  end
  scope :rejected do |transaction|
    transaction.where(:status => "rejected")
  end  
  scope :rejected do |transaction|
    transaction.where(:status => "cancelled")
  end  
  
  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |t|
      link_to t.id, admin_mtg_transaction_path(t)
    end
    column "Number", :transaction_number
    column :buyer
    column :seller
    column "Items", :sortable => false do |transaction|
       link_to transaction.items.sum(:quantity), admin_mtg_transaction_items_path("q[transaction_id_eq]" => transaction.id)
    end
    column :subtotal_value, :sortable => false do |transaction|
      number_to_currency(transaction.subtotal_value)
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
  filter :buyer_feedback
  filter :created_at
  filter :updated_at
  filter :sold_at  

end
