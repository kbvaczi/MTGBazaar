# encoding: UTF-8
ActiveAdmin.register Mtg::Transactions::Item do
  menu :label => "5 --- Transaction Items", :parent => "MTG"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
  
  # ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true do |item|
    item.includes({:card => :set}, :transaction => [:seller, :buyer])
  end
    
  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index :title => "Sold Cards (MTG Transaction Items)" do
    column :id, :sortable => :id do |l|
      link_to l.id, admin_mtg_transactions_item_path(l)
    end
    column 'Transaction', :sortable => :'transaction.transaction_number'  do |item|
      link_to item.transaction.transaction_number, admin_mtg_transaction_path(item.transaction)
    end
    column :buyer, :sortable => false do |i|
      i.transaction.buyer.username rescue "ERROR"
    end
    column :seller, :sortable => false do |i|
      i.transaction.seller.username rescue "ERROR"
    end
    column "Card", :sortable => false do |l|
      link_to display_name(l.card.name), admin_mtg_card_path(l.card.id)
    end
    column "Set", :sortable => false do |l|
      link_to display_set_symbol(l.card.set), admin_mtg_set_path(l.card.set.id)
    end
    column "Price", :sortable => :price do |l|
      number_to_currency(l.price.dollars)
    end
    column 'Quantity', :sortable => :quantity_requested do |item|
      item.quantity_requested
    end
    column "Lng", :sortable => :language do |item|
      display_flag_symbol(item.language)
    end
    column 'Cnd', :sortable => :condition do |item|
      display_condition(item.condition)
    end
    column "F", :sortable => :foil do |l| 
      listing_option_foil_icon if l.foil
    end    
    column "M", :sortable => :misprint do |l| 
      listing_option_misprint_icon if l.misprint
    end
    column "A", :sortable => :altart do |l| 
      listing_option_altart_icon if l.altart
    end        
    column "S", :sortable => :signed do |l| 
      listing_option_signed_icon if l.signed
    end  
    column :description
    column :created_at
    column :updated_at
  end
  
  # ------ FILTERS FOR INDEX ------- #
  filter :transaction_transaction_number, :as => :select, :collection => Mtg::Transaction.pluck(:transaction_number), :input_html => {:class => "chzn-select"}   
  filter :buyer,        :as => :select,   :input_html => {:class => "chzn-select"}
  filter :seller,       :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :price,        :label => "Price (in cents)"
  filter :language,     :as => :select,   :collection => language_list, :input_html => {:class => "chzn-select"}    
  filter :condition,    :as => :select,   :collection => condition_list, :input_html => {:class => "chzn-select"}    
  filter :misprint,     :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :altart,       :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :signed,       :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :foil,         :as => :select,   :input_html => {:class => "chzn-select"}
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
      row :created_at
      row :updated_at    
    end
    active_admin_comments
  end
end
