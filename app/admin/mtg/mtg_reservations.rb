# encoding: UTF-8
ActiveAdmin.register Mtg::Reservation do
  menu :label => "2 - Reservations", :parent => "Carts"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class
  extend UsersHelper    

# ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
   
# ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true do |reservations|
    reservations.includes(:cart, :listing => [:card, :seller])
  end   
  scope "Custom Filter" do |reservations|
    if params[:custom_filter]
      reservations.includes(:cart, :listing => [{:card => :set}, :seller]).where("#{params[:custom_filter]}")
    else
      reservations.where(:id => 0)
    end    
  end
   
# ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => false do |reservation|
      link_to reservation.id, admin_mtg_reservation_path(reservation)
    end
    column "Buyer", :sortable => false do |r|
      r.cart.user.username
    end
    column :seller, :sortable => "users.username"
    column "Card", :sortable => "mtg_cards.name" do |l|
      link_to display_name(l.card.name), admin_mtg_card_path(l.card.id)
    end
    column "Set", :sortable => "mtg_sets.name" do |l|
      link_to display_set_symbol(l.card.set), admin_mtg_set_path(l.card.set.id)
    end
    column "L", :sortable => "mtg_listings.language" do |l|
      display_flag_symbol(l.listing.language)
    end
    column "Cnd", :sortable => "mtg_listings.condition" do |l|
      display_condition(l.listing.condition)
    end
    column "F", :sortable => "mtg_listings.foil" do |l| 
      listing_option_foil_icon if l.listing.foil
    end    
    column "M", :sortable => "mtg_listings.misprint" do |l| 
      listing_option_misprint_icon if l.listing.misprint
    end
    column "A", :sortable => "mtg_listings.altart" do |l| 
      listing_option_altart_icon if l.listing.altart
    end        
    column "S", :sortable => "mtg_listings.signed" do |l| 
      listing_option_signed_icon if l.listing.signed
    end
    column "Scan", :sortable => false do |l|
      link_to listing_option_scan_icon(l.listing), l.listing.scan_url, :target => "_blank" if l.listing.scan?
    end
    column "Description", :sortable => false do |r|
      r.listing.description
    end
    column "$", :sortable => :false do |l|
      number_to_currency(l.listing.price.dollars)
    end
    column "Qty", :sortable => false do |l|
      l.quantity
    end
    column :updated_at
  end
  
# ------ FILTERS FOR INDEX ------- #
  filter :listing_card_name,          :label => "Card Name", :as => :string, :input_html => {:class => "ui-autocomplete-input" , "data-type" => "search", "data-autocomplete" => '/mtg/cards/autocomplete_name.json' }  
  filter :listing_card_set_code,      :label => "Set",       :as => :select, :collection => Proc.new {active_set_list},   :input_html => {:class => "chzn-select"}    
  filter :listing_seller_username,    :label => "Seller",    :as => :select, :collection => Proc.new {users_list}, :input_html => {:class => "chzn-select"}  
  filter :cart_user_username,         :label => "Buyer",     :as => :select, :collection => Proc.new {users_list}, :input_html => {:class => "chzn-select"}    
  filter :listing_price,              :label => "Price (in cents)"
  filter :listing_language,     :as => :select,   :collection => language_list,   :input_html => {:class => "chzn-select"}    
  filter :listing_condition,    :as => :select,   :collection => condition_list,  :input_html => {:class => "chzn-select"}    
  filter :listing_misprint,     :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :listing_altart,       :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :listing_signed,       :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :listing_foil,         :as => :select,   :input_html => {:class => "chzn-select"}          
  filter :created_at
  filter :updated_at
  

end
