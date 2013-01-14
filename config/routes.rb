MTGBazaar::Application.routes.draw do

# ACTIVE ADMIN SETUP ------- #

  ActiveAdmin.routes(self)
  
# ADMIN USERS -------------- #

  devise_for :admin_users, ActiveAdmin::Devise.config
 
# SHOPPING CART ------------- #

  post    "mtg/cards/listings/:id/add_to_cart"      => "carts#add_mtg_cards",             :as => 'add_to_cart_mtg_listing'      
  delete  "mtg/cards/listings/:id/remove_from_cart" => "carts#remove_mtg_cards",          :as => 'remove_from_cart_mtg_listing'
  post    "mtg/cards/listings/:id/update_quantity"          => "carts#update_quantity_mtg_cards", :as => 'update_quantity_in_cart_mtg_cards'

  get     'mtg/cart'                                      => 'carts#show',                    :as => 'show_cart'

  
# TICKETS ------------------- #

  resources :tickets, :only => [:index, :show, :new, :create] 
  post    "tickets/:id/update"                => "tickets#create_update",            :as => 'ticket_update'
  
  
# COMMUNICATIONS ------------ #

  resources :communications, :only => [:index, :show, :create]

# MTG ----------------------- #

  # Orders
  
  post  'orders/:id/checkout'                 => 'mtg/orders#checkout',                :as => 'order_checkout'
  get   'orders/:id/checkout_success'         => 'mtg/orders#checkout_success',        :as => 'order_checkout_success'  
  get   'orders/:id/checkout_failure'         => 'mtg/orders#checkout_failure',        :as => 'order_checkout_failure'
  post  'orders/:id/update_shipping_options'  => 'mtg/orders#update_shipping_options', :as => 'order_update_shipping_options'
  
  # listings
  
  put   "mtg/cards/listings/:id/set_active"       => "mtg/cards/listings#set_active",         :as => 'mtg_cards_listing_set_active'  
  put   "mtg/cards/listings/:id/set_inactive"     => "mtg/cards/listings#set_inactive",       :as => 'mtg_cards_listing_set_inactive'  

  # transactions
  get   'transactions/:id'                => 'mtg/transactions#show',                                 :as => 'show_mtg_transaction'
  get   'transactions/:id/confirm'        => 'mtg/transactions#seller_sale_confirmation',             :as => 'seller_sale_confirmation'      
  put   'transactions/:id/confirm'        => 'mtg/transactions#create_seller_sale_confirmation',      :as => 'create_seller_sale_confirmation'    
  get   'transactions/:id/reject'         => 'mtg/transactions#seller_sale_rejection',                :as => 'seller_sale_rejection'
  put   'transactions/:id/reject'         => 'mtg/transactions#create_seller_sale_rejection',         :as => 'create_seller_sale_rejection'  
  get   'transactions/:id/cancel'         => 'mtg/transactions#buyer_sale_cancellation',              :as => 'mtg_transaction_buyer_sale_cancellation'  
  put   'transactions/:id/cancel'         => 'mtg/transactions#create_buyer_sale_cancellation',       :as => 'mtg_transaction_create_buyer_sale_cancellation'    
  get   'transactions/:id/buyer_feedback' => 'mtg/transactions#buyer_sale_feedback',                  :as => 'buyer_sale_feedback'
  put   'transactions/:id/buyer_feedback' => 'mtg/transactions#create_buyer_sale_feedback',           :as => 'create_buyer_sale_feedback'  
  get   'transactions/:id/shipment'       => 'mtg/transactions#seller_shipment_confirmation',         :as => 'seller_shipment_confirmation'
  put   'transactions/:id/shipment'       => 'mtg/transactions#create_seller_shipment_confirmation',  :as => 'create_seller_shipment_confirmation'
  get   'transactions/:id/delivery'       => 'mtg/transactions#buyer_delivery_confirmation',          :as => 'buyer_delivery_confirmation'
  put   'transactions/:id/delivery'       => 'mtg/transactions#create_buyer_delivery_confirmation',   :as => 'create_buyer_delivery_confirmation'  
  get   'transactions/:id/invoice'        => 'mtg/transactions#show_invoice',                         :as => 'show_invoice'
  put   'transactions/:id/pickup_confirm' => 'mtg/transactions#pickup_confirmation',                  :as => 'pickup_confirmation'

  get   'transactions/:id/feedback'           => 'mtg/transactions/feedback#new',                     :as => 'new_feedback'
  post  'transactions/:id/feedback'           => 'mtg/transactions/feedback#create',                  :as => 'create_feedback'
  get   'transactions/:id/feedback/response'  => 'mtg/transactions/feedback#new_response',            :as => 'new_feedback_response'
  post  'transactions/:id/feedback/response'  => 'mtg/transactions/feedback#create_response',         :as => 'create_feedback_response'

  # shipping labels
  
  get   'transactions/:id/shipping_label' => 'mtg/transactions/shipping_labels#create',   :as => 'create_shipping_label'
  get   'transactions/:id/track'          => 'mtg/transactions/shipping_labels#track',    :as => 'track_shipping'  
  
  # payments
  
  post   'transactions/:id/payment_notification' => 'mtg/transactions/payment_notifications#payment_notification', :as => 'payment_notification'
  
  namespace :mtg do 
    namespace :cards do
      post   "listings/multiple/set_active"       => "edit_multiple_listings#set_active",         :as => 'listings_multiple_set_active'  
      post   "listings/multiple/set_inactive"     => "edit_multiple_listings#set_inactive",       :as => 'listings_multiple_set_inactive'        
      post   "listings/multiple/delete"           => "edit_multiple_listings#delete",             :as => 'listings_multiple_delete'              
      post   "listings/multiple/process_request"  => "edit_multiple_listings#process_request",    :as => 'listings_multiple_process_request'
      resources :listings_playsets, :only => [:new, :edit, :update, :create], :path => "listings/playsets" do
        get "playset_pricing_ajax", :as => "playset_pricing_ajax", :on => :collection
      end
      resources :listings, :except => [:index, :show ] do
        get "new_generic", :as => "new_generic", :on => :collection
        get "new_generic_pricing", :as => "new_generic_pricing", :on => :collection                  
        get "new_generic_set", :as => "new_generic_set", :on => :collection  
        post "create_generic", :as => "create_generic", :on => :collection   
        get "new_bulk_prep", :as => "new_bulk_prep", :on => :collection
        get "new_bulk", :as => "new_bulk", :on => :collection      
        post "create_bulk", :as => "create_bulk", :on => :collection
        get "get_pricing", :on => :collection        
      end

    end

    get  'cards/autocomplete_name' => 'cards#autocomplete_name', :as => 'cards_autocomplete_name'
    get  'cards/search'            => 'cards#search',            :as => 'cards_search'
    post 'cards/search'            => 'cards#search',            :as => 'cards_search'    
    get  'cards/(:set)'            => 'cards#index',             :as => 'cards'
    get  'card/:id'                => 'cards#show',              :as => 'card'
    
  end
  
# USERS -------------------- #

  get  'account'           => 'users#account_info',      :as => 'account_info'  
  get  'account/listings'  => 'users#account_listings',  :as => 'account_listings'
  get  'account/sales'     => 'users#account_sales',     :as => 'account_sales'
  post 'account/sales'     => 'users#account_sales',     :as => 'account_sales'   # for pagination
  get  'account/purchases' => 'users#account_purchases', :as => 'account_purchases'
  post 'account/purchases' => 'users#account_purchases', :as => 'account_purchases'   # for pagination

  devise_for :users, :path => '/account', :controllers => { :registrations => 'account/registrations', :sessions => 'account/sessions', :passwords => 'account/passwords' } 
  devise_scope :user do
    get 'account/sign_up/verify_address' => 'account/registrations#verify_address', :as => "sign_up_verify_address"
    get 'account/sign_up/verify_paypal'  => 'account/registrations#verify_paypal',  :as => "sign_up_verify_paypal"    
  end

  # resources :users must be declared after devise_for because earlier declarations take precedence 
  # see http://stackoverflow.com/questions/5051487/combining-devise-with-resources-users-in-rails
  resources :users, :only => [:index, :show] do
    get  :autocomplete_name,      :on => :collection
    get  :autocomplete_name_chosen,      :on => :collection    
    post :seller_status_toggle,   :on => :collection
    get  :validate_username_ajax, :on => :collection
  end
  #match 'users/:id/(:page)', :controller => 'users', :action => 'show'  #TODO: hack to get pagination to work in user show page... relook at this later

# NEWS FEEDS

  resources :news_feeds, :only => [:show, :index], :path => '/news'
  
# TEAM Z
  namespace :team_z do
    resources :articles do
      get  'edit_to_publish', :on => :member
      put  'publish',         :on => :member
      put  'unpublish',       :on => :member
    end
    resources :profiles, :only => [:show]
    resources :mtgo_video_series, :only => [:show, :index]
  end

# MISC ROUTES -------------- #

  root :to => "home#index"
  match 'about'               => 'home#about'
  match 'terms'               => 'home#terms'
  match 'privacy'             => 'home#privacy'
  match 'condition'           => 'home#condition'
  match 'contact'             => 'contact#index'
  match 'contact_create'      => 'contact#create'
  match 'copyright'           => 'home#copyright'
  match 'help'                => 'home#help'
  match 'faq'                 => 'home#faq'
  match 'feedback'            => 'home#feedback'
  match 'welcome'             => 'home#welcome'
  match 'sitemap'             => 'home#sitemap'
  mount Ckeditor::Engine      => "/ckeditor"
  
  
  if Rails.env.development?
    match 'test'              => 'home#test'
  end
  
  # VANITY URLs for users
  get  ':id/(:section)' => 'users#show', :constraints => {:id => /.+?(?<!ico)/, :format => /(html|xml|js|json)/}, :as => 'user'  
  
# RAILS STANDARD COMMENTS ----------- #
  
  #match "*a" => redirect('/') # send all random routes to home
   
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
