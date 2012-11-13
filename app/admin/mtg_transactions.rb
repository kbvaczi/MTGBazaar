# encoding: UTF-8
ActiveAdmin.register Mtg::Transaction do
  menu :label => "5 - Transactions", :parent => "MTG"
  #menu :label => "Transactions", :parent => "MTG"
  #extend Mtg::CardsHelper   # access mtg_card helpers inside this class

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
  
  # ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true do |t|
    t.includes(:items, :feedback, :buyer, :seller, :shipping_label)
  end
  scope :confirmed do |transaction|
    transaction.where(:status => "confirmed")
  end  
  scope :shipped do |transaction|
    transaction.where(:status => "shipped")
  end
  scope "With Feedback" do |transaction|
    transaction.where(:status => "completed")
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
       link_to transaction.items.sum(:quantity_requested), admin_mtg_transactions_items_path("q[transaction_transaction_number_eq]" => transaction.transaction_number)
    end
    column 'value', :sortable => :value do |t|
      number_to_currency(t.value)
    end
    column 'Shipping', :sortable => :shipping_cost do |t|
      number_to_currency(t.shipping_cost)
    end    
    column 'Label Cost', :sortable => "mtg_transactions_shipping_labels.price" do |t|
      link_to number_to_currency(t.shipping_label.price), t.shipping_label.params[:url], :target => "_blank" rescue ""      
    end  
    column "Status", :sortable => :status do |transaction|
      transaction.status
    end
    column "Shipped", :seller_shipped_at
    column "Feedback", :sortable => "mtg_transactions_feedback.rating" do |t|
      t.feedback.display_rating rescue ""
    end
    column "Feedback Comment", :sortable => false do |t|
      t.feedback.comment rescue ""
    end
    column "Feedback Response", :sortable => false do |t|
      t.feedback.seller_response_comment rescue ""
    end    
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
