# encoding: UTF-8
ActiveAdmin.register Cart do
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
   
  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |cart|
      link_to cart.id, admin_cart_path(cart)
    end
    column "User", :sortable => :user_id do |cart|
      if cart.user_id 
        link_to User.find(cart.user_id).username, admin_users_path(cart.user_id)
      else
        "Anonymous"
      end
    end
    column "MTG Cards", :sortable => false do |cart|
      link_to cart.mtg_listings.count, admin_mtg_listings_path("q[cart_id_eq]" => cart.id) if not cart.mtg_listings.empty?
    end
    column "Total Price", :sortable => :total_price do |cart|
      number_to_currency(cart.total_price.dollars)
    end
    #column :created_at
    #column :updated_at
  end
=begin  
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
=end
end
