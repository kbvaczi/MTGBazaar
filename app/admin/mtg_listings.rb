# encoding: UTF-8
ActiveAdmin.register Mtg::Cards::Listing do
  menu :label => "4 - Listings", :parent => "MTG"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
  
  # ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true
  scope :active do |listings|
    listings.active
  end
  scope :inactive do |listings|
    listings.inactive
  end
  
  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |l|
      link_to l.id, admin_mtg_listing_path(l)
    end
    column :seller
    column "Card", :sortable => false do |l|
      link_to display_name(l.card.name), admin_mtg_card_path(l.card.id)
    end
    column "Set", :sortable => false do |l|
      link_to l.card.set.name, admin_mtg_set_path(l.card.set.id)
    end
    column "Price", :sortable => :price do |l|
      number_to_currency(l.price.dollars)
    end
    column "Reserved", :quantity_reserved, :sortable => false
    column "Available", :quantity_available
    column "Total", :quantity
    column :language
    column :condition
    column :misprint
    column "Alt Art", :altart
    column :signed
    column :foil
    column :description
    column :created_at
    column :updated_at
    column :active
  end
  
  # ------ FILTERS FOR INDEX ------- #
  filter :seller, :as => :select, :input_html => {:class => "chzn-select"}    
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
  show do |listing|
    attributes_table do
      row :id
      row :seller
      row "Card" do
        link_to "#{display_name(listing.card.name)} (#{listing.card.set.name})", admin_mtg_card_path(listing.card.id)
      end
      row :language
      row :condition
      row :misprint
      row :description
      row :cart do 
        link_to listing.cart_id, admin_mtg_listings_path("q[cart_id_eq]" => listing.cart_id) if listing.cart_id
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
