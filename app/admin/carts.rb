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
    column "MTG Cards", :sortable => :item_count do |cart|
      link_to cart.item_count, admin_mtg_listings_path("q[cart_id_eq]" => cart.id) if cart.item_count > 0
    end
    column "Total Price", :sortable => :total_price do |cart|
      number_to_currency(cart.total_price.dollars)
    end
    #column :created_at
    #column :updated_at
  end

end
