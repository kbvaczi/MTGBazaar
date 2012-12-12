# encoding: UTF-8
ActiveAdmin.register Mtg::Transactions::ShippingLabel do

  menu :label => "2 - Shipping Labels", :parent => "Transactions"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class
  
  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
   
  # ------ SCOPES ------- #
  begin
    scope :all do |labels|
      labels.scoped
    end  
    scope :shipped, :default => true do |labels|
      labels.joins(:transaction).where("mtg_transactions.seller_shipped_at is not NULL")
    end
    scope "Not Shipped" do |labels|
      labels.joins(:transaction).where("mtg_transactions.seller_shipped_at is NULL")
    end    
    scope "Refunded" do |labels|
      labels.where(:status => "refunded")
    end    
  end   

  # ------ INDEX ------- #
  # Customize columns displayed on the index screen in the table   
  index :title => "Shipping Labels" do
    column :id, :sortable => :id do |label|
      link_to label.id, admin_mtg_transactions_shipping_label_path(label)
    end
    column :created_at
    column :updated_at
  end
  
  # ------ FILTERS FOR INDEX ------- #


  ##### ----- Custom Show Screen ----- #####
end
