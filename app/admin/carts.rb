# encoding: UTF-8
ActiveAdmin.register Cart do
  menu :label => "1 - Carts", :parent => "Carts"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class

# ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
   
# ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true do |carts|
    carts.includes(:user, :orders)
  end   
  scope "Custom Filter" do |carts|
    if params[:custom_filter]
      carts.includes(:user, :orders).where("#{params[:custom_filter]}")
    else
      carts.where(:id => 0)
    end
  end  
   
# ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |cart|
      link_to cart.id, admin_cart_path(cart)
    end
    column "Buyer", :sortable => :user_id do |cart|
      if cart.user_id 
        link_to User.find(cart.user_id).username, admin_user_path(cart.user_id)
      else
        "Anonymous"
      end
    end
    column "Orders", :sortable => false do |cart|
      link_to cart.orders.to_a.count, admin_mtg_orders_path(:custom_filter => "mtg_orders.cart_id = #{cart.id}", :scope => "custom_filter")
    end
    column "MTG Cards", :sortable => :item_count do |cart|
      #link_to cart.item_count, admin_mtg_cards_listings_path("q[carts_id_eq]" => cart.id) if cart.item_count > 0
      if cart.item_count > 0      
        link_to cart.item_count, admin_mtg_reservations_path(:custom_filter => "carts.id = #{cart.id}", :scope => "custom_filter") 
      else
        0
      end
    end
    column "Total Price", :sortable => :total_price do |cart|
      number_to_currency(cart.total_price.dollars)
    end
    #column :created_at
    column :updated_at
  end

# ------ SHOW PAGE CUSTOMIZATIONS ------ #

show  do |cart|
  attributes_table do
    row :id
    row "Buyer" do
      cart.user.username
    end
    row :created_at
    row :updated_at
  end
  active_admin_comments
end



end
