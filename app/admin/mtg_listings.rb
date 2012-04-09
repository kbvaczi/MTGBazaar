# encoding: UTF-8
ActiveAdmin.register Mtg::Listing do
  menu :label => "Listings", :parent => "MTG"
  #extend Mtg::CardsHelper   # access mtg_card helpers inside this class

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
  scope :reserved do |listings|
    listings.reserved
  end
  scope :sold do |listings|
    listings.sold
  end
  scope :rejected do |listings|
    listings.rejected
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
    column :language
    column :condition
    column :defect
    column :description
    column :cart, :sortable => false do |l| 
      link_to l.cart_id, admin_mtg_listings_path("q[cart_id_eq]" => l.cart_id) if l.cart_id
    end
    column :created_at
    column :updated_at
    column :sold_at
    column :rejected_at    
    column :active
  end
  
  # ------ FILTERS FOR INDEX ------- #
  filter :seller, :as => :select, :input_html => {:class => "chzn-select"}    
  filter :price, :label => "Price (in cents)"
  filter :language, :as => :select, :collection => language_list, :input_html => {:class => "chzn-select"}    
  filter :condition, :as => :select, :collection => condition_list, :input_html => {:class => "chzn-select"}    
  filter :defect
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
      row :defect
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
