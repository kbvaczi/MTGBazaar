# encoding: UTF-8
ActiveAdmin.register Mtg::Order do
  menu :label => "2 - Orders", :parent => "Carts"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class

# ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
   
# ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true do |orders|
    orders.includes(:seller, :cart => :user)
  end   
  scope "Custom Filter" do |orders|
    orders.includes(:seller, :cart => :user).where("#{params[:custom_filter]}")
  end
   
# ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |order|
      link_to order.id, admin_mtg_order_path(order)
    end
    column "Buyer", :sortable => "users.username" do |order|
      if order.cart.user
        link_to order.cart.user.username, admin_user_path(order.cart.user.id)
      else
        "ERROR"
      end
    end
    column "Seller", :sortable => "users.username" do |order|
      if order.seller
        link_to order.seller.username, admin_user_path(order.seller_id)
      else
        "ERROR"
      end
    end
    column "Cards", :sortable => :item_count do |order|
      order.item_count
    end
    column "Total", :sortable => :item_price_total do |order|
      number_to_currency(order.item_price_total)
    end    
    #column :created_at
    column :updated_at
  end

end
