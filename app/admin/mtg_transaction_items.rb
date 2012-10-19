# encoding: UTF-8
ActiveAdmin.register Mtg::Transactions::Item do
  menu :label => "5 --- Transaction Items", :parent => "MTG"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
  
  # ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true do |item|
    item.includes [:transaction]
  end
    
  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index :title => "test" do
    column :id, :sortable => :id do |l|
      link_to l.id, admin_mtg_transactions_item_path(l)
    end
    column 'Transaction', :sortable => :'transaction.transaction_number'  do |item|
      link_to item.transaction.transaction_number, admin_mtg_transaction_path(item.transaction)
    end
    column :seller, :sortable => false do |i|
      i.seller.username rescue "ERROR"
    end
    column "Card", :sortable => false do |l|
      link_to display_name(l.card.name), admin_mtg_card_path(l.card.id)
    end
    column "Set", :sortable => false do |l|
      link_to l.card.set.name, admin_mtg_set_path(l.card.set.id)
    end
    column "Price", :sortable => :price do |l|
      number_to_currency(l.price.dollars)
    end
    column :quantity_requested
    column :language
    column :condition
    column :misprint
    column :altart
    column :signed
    column :foil
    column :description
    column :created_at
    column :updated_at
  end
  
  # ------ FILTERS FOR INDEX ------- #
  filter :transaction_transaction_number, :as => :string#, :collection => Mtg::Transaction.all.map(&:transaction_number), :input_html => {:class => "chzn-select"}   
  filter :seller, :as => :select, :input_html => {:class => "chzn-select"}    
  filter :buyer, :as => :select, :input_html => {:class => "chzn-select"}
  filter :price, :label => "Price (in cents)"
  filter :language, :as => :select, :collection => language_list, :input_html => {:class => "chzn-select"}    
  filter :condition, :as => :select, :collection => condition_list, :input_html => {:class => "chzn-select"}    
  filter :misprint
  filter :created_at
  filter :updated_at
  filter :sold_at  
  filter :status
  
  # ------ SHOW PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the show screen in the table
  show do |item|
    attributes_table do
      row :id
      row :seller
      row "Card" do
        link_to "#{display_name(item.card.name)} (#{item.card.set.name})", admin_mtg_card_path(item.card.id)
      end
      row :language
      row :condition
      row :misprint
      row :description
      row :cart do 
        link_to item.cart_id, admin_mtg_transaction_items_path("q[cart_id_eq]" => item.cart_id) if item.cart_id
      end
      row :created_at
      row :updated_at
      row :sold_at
      row :rejected_at    
      row :active
    end
    active_admin_comments
  end
end
