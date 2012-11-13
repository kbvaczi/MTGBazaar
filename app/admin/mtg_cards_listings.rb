# encoding: UTF-8
ActiveAdmin.register Mtg::Cards::Listing do
  menu :label => "4 - Listings", :parent => "MTG"
  extend Mtg::CardsHelper   # access mtg_card helpers inside this class
  extend UsersHelper  

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  config.clear_action_items! #clear standard buttons
  
  # ------ SCOPES (auto sorts) ------ #
  scope :all, :default => true do |listings|
    listings.includes(:seller, :card => :set).includes(:reservations => {:order => :cart})
  end
  scope :active do |listings|
    listings.includes(:seller, :card => :set).includes(:reservations => {:order => :cart}).active
  end
  scope :inactive do |listings|
    listings.includes(:seller, :card => :set).includes(:reservations => {:order => :cart}).inactive
  end
  scope "Custom Filter" do |listings|
    if params[:custom_filter]
      listings.includes(:seller, :card => :set).includes(:reservations => {:order => :cart}).where("#{params[:custom_filter]}")
    else
      listings.where(:id => 0)
    end    
  end
  
  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => false do |l|
      link_to l.id, admin_mtg_cards_listing_path(l)
    end
    column :seller, :sortable => "users.username"
    column "Card", :sortable => "mtg_cards.name" do |l|
      link_to display_name(l.card.name), admin_mtg_card_path(l.card.id)
    end
    column "Set", :sortable => "mtg_sets.name" do |l|
      link_to display_set_symbol(l.card.set), admin_mtg_set_path(l.card.set.id)
    end
    column "L", :sortable => :language do |l|
      display_flag_symbol(l.language)
    end
    column "Cnd", :sortable => :condition do |l|
      display_condition(l.condition)
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
    column "Scan", :sortable => false do |l|
      link_to listing_option_scan_icon(l), l.scan_url, :target => "_blank" if l.scan?
    end
    column :description
    column "$", :sortable => :price do |l|
      number_to_currency(l.price.dollars)
    end
    column "Rsvd", :sortable => false do |l|
      l.reservations.to_a.inject(0) {|sum, res| sum + res.quantity}
    end
    column "Avail", :quantity_available
    column "Total", :quantity    
    column "Actv", :active
  end
  
  # ------ FILTERS FOR INDEX ------- #
  filter :card_name_contains, :label => "Card Name", :as => :autocomplete, :url => '/mtg/cards/autocomplete_name.json', :required => false, :wrapper_html => {:style => "list-style: none;margin-bottom:10px;"}  
  filter :card_set_code,      :label => "Set",       :as => :select, :collection => active_set_list,   :input_html => {:class => "chzn-select"}    
  filter :seller_username,    :label => "Seller",    :as => :select, :collection => users_list, :input_html => {:class => "chzn-select"}  
  filter :price,              :label => "Price (in cents)"
  filter :language,     :as => :select,   :collection => language_list,   :input_html => {:class => "chzn-select"}    
  filter :condition,    :as => :select,   :collection => condition_list,  :input_html => {:class => "chzn-select"}    
  filter :misprint,     :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :altart,       :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :signed,       :as => :select,   :input_html => {:class => "chzn-select"}    
  filter :foil,         :as => :select,   :input_html => {:class => "chzn-select"}          
  filter :created_at
  filter :updated_at
  filter :sold_at  
  filter :status
  filter :cart
  
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
      row :created_at
      row :updated_at    
      row :active
    end
    active_admin_comments
  end
end
