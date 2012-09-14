MTGBazaar::Application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

# ACTIVE ADMIN SETUP ------- #

  ActiveAdmin.routes(self)
  
# ADMIN USERS -------------- #

  devise_for :admin_users, ActiveAdmin::Devise.config
 
# SHOPPING CART ------------- #

  post    "mtg/listings/:id/add_to_cart"      => "carts#add_mtg_cards",             :as => 'add_to_cart_mtg_listing'      
  delete  "mtg/listings/:id/remove_from_cart" => "carts#remove_mtg_cards",          :as => 'remove_from_cart_mtg_listing'
  post    "mtg/listings/:id/update_quantity"  => "carts#update_quantity_mtg_cards", :as => 'update_quantity_in_cart_mtg_cards'  

  get     'mtg/cart'                          => 'users#show_cart',                 :as => 'show_cart'
  post    'mtg/checkout'                      => 'carts#checkout',                  :as => 'cart_checkout'
  
# TICKETS ------------------- #

  resources :tickets, :only => [:index, :show, :new, :create] 
  post    "tickets/:id/update"                => "tickets#create_update",            :as => 'ticket_update'
  
# MTG ----------------------- #

  # listings
  
  put     "mtg/listings/:id/set_active"       => "mtg/listings#set_active",         :as => 'mtg_listing_set_active'  
  put     "mtg/listings/:id/set_inactive"     => "mtg/listings#set_inactive",       :as => 'mtg_listing_set_inactive'  

  # transactions
  get   'transactions/:id'                => 'mtg/transactions#show',                                 :as => 'show_mtg_transaction'
  get   'transactions/:id/confirm'        => 'mtg/transactions#seller_sale_confirmation',             :as => 'seller_sale_confirmation'      
  put   'transactions/:id/confirm'        => 'mtg/transactions#create_seller_sale_confirmation',      :as => 'create_seller_sale_confirmation'    
  get   'transactions/:id/reject'         => 'mtg/transactions#seller_sale_rejection',                :as => 'seller_sale_rejection'
  put   'transactions/:id/reject'         => 'mtg/transactions#create_seller_sale_rejection',         :as => 'create_seller_sale_rejection'  
  get   'transactions/:id/modify'         => 'mtg/transactions#seller_sale_modification',             :as => 'seller_sale_modification'
  put   'transactions/:id/modify'         => 'mtg/transactions#create_seller_sale_modification',      :as => 'create_seller_sale_modification'  
  get   'transactions/:id/review'         => 'mtg/transactions#buyer_sale_modification_review',       :as => 'buyer_sale_modification_review'
  put   'transactions/:id/review'         => 'mtg/transactions#create_buyer_sale_modification_review',:as => 'create_buyer_sale_modification_review'
  get   'transactions/:id/cancel'         => 'mtg/transactions#buyer_sale_cancellation',              :as => 'mtg_transaction_buyer_sale_cancellation'  
  put   'transactions/:id/cancel'         => 'mtg/transactions#create_buyer_sale_cancellation',       :as => 'mtg_transaction_create_buyer_sale_cancellation'    
  get   'transactions/:id/buyer_feedback' => 'mtg/transactions#buyer_sale_feedback',                  :as => 'buyer_sale_feedback'
  put   'transactions/:id/buyer_feedback' => 'mtg/transactions#create_buyer_sale_feedback',           :as => 'create_buyer_sale_feedback'  
  get   'transactions/:id/shipment'       => 'mtg/transactions#seller_shipment_confirmation',         :as => 'seller_shipment_confirmation'
  put   'transactions/:id/shipment'       => 'mtg/transactions#create_seller_shipment_confirmation',  :as => 'create_seller_shipment_confirmation'
  get   'transactions/:id/delivery'       => 'mtg/transactions#buyer_delivery_confirmation',          :as => 'buyer_delivery_confirmation'
  put   'transactions/:id/delivery'       => 'mtg/transactions#create_buyer_delivery_confirmation',   :as => 'create_buyer_delivery_confirmation'  

  # shipping labels
  
  get   'transactions/:id/shipping_label' => 'mtg/transactions/shipping_labels#create',   :as => 'create_shipping_label'
  
  namespace :mtg do
    
    resources :listings, :except => [:index, :show ] do
      get "new_generic", :as => "new_generic", :on => :collection
      get "new_generic_pricing", :as => "new_generic_pricing", :on => :collection                  
      get "new_generic_set", :as => "new_generic_set", :on => :collection  
      post "create_generic", :as => "create_generic", :on => :collection   
      get "new_bulk_prep", :as => "new_bulk_prep", :on => :collection
      get "new_bulk", :as => "new_bulk", :on => :collection      
      post "create_bulk", :as => "create_bulk", :on => :collection            

    end
       
    resources :cards, :only => [:index, :show] do # don't allow users to create/destroy mtg cards by only allowing index and show routes
      get  "autocomplete_name", :on => :collection
      get  "search", :as => 'search', :on => :collection  # can't figure out how to send autocorrect click link via post so we need get too for now
      post "search", :as => 'search', :on => :collection
      put  "search", :as => 'search', :on => :collection            
    end
    
  end
  
# USERS -------------------- #

  # resources :users must be declared after devise_for because earlier declarations take precedence 
  # see http://stackoverflow.com/questions/5051487/combining-devise-with-resources-users-in-rails

  get 'account' => 'users#show_account_info', :as => 'show_account_info'  
  get 'account/listings' => 'users#display_current_listings', :as => 'user_current_listings'
  get 'account/sales' => 'users#account_sales', :as => 'account_sales'
  post 'account/sales' => 'users#account_sales', :as => 'account_sales'   # for pagination
  get 'account/purchases' => 'users#account_purchases', :as => 'account_purchases'
  post 'account/purchases' => 'users#account_purchases', :as => 'account_purchases'   # for pagination  

  devise_for :users, :controllers => { :registrations => 'users/registrations', :sessions => 'users/sessions', :passwords => 'users/passwords' }
  resources :users, :only => [:index, :show], :controllers => { :users => "users/users"} do
    get "autocomplete_name", :on => :collection
    get :autocomplete_user_username, :on => :collection
  end
  match 'users/:id/(:page)', :controller => 'users', :action => 'show'  #TODO: hack to get pagination to work in user show page... relook at this later

  #resources :accounts
  
# ACCOUNT BALANCE TRANSFERS
  
  get 'account/funding'   => 'account_balance_transfers#index',                   :as => 'account_funding_index'
  get 'account/deposit'   => 'account_balance_transfers#new_account_deposit',     :as => 'new_account_deposit'
  post 'account/deposit'  => 'account_balance_transfers#create_account_deposit',  :as => 'create_account_deposit'
  get 'account/withdraw'  => 'account_balance_transfers#new_account_withdraw',    :as => 'new_account_withdraw'
  post 'account/withdraw' => 'account_balance_transfers#create_account_withdraw', :as => 'create_account_withdraw'
  
  # payment notifications
  post  'payment_notifications/create_deposit_notification'   => 'payment_notifications#create_deposit_notification',   :as => 'create_deposit_notification'
  post  'payment_notifications/create_withdraw_notification'  => 'payment_notifications#create_withdraw_notification',  :as => 'create_withdraw_notification'  
  get   'payment_notifications/acknowledge_deposit'           => 'payment_notifications#acknowledge_deposit',           :as => "acknowledge_deposit"
  get   'payment_notifications/cancel_deposit'                => 'payment_notifications#cancel_deposit',                :as => "cancel_deposit"  
  
# NEWS FEEDS

  resources :news_feeds, :only => [:show, :index], :path => '/news'
  
# MISC ROUTES -------------- #

  root :to => "home#index"
  match 'about'               => 'home#about'
  match 'terms'               => 'home#terms_of_service'
  match 'privacy'             => 'home#privacy'
  match 'condition'           => 'home#condition'
  match 'contact'             => 'contact#index'
  match 'contact_create'      => 'contact#create'
  match 'help'                => 'home#help'
  match 'faq'                 => 'home#faq'
  match 'feedback'            => 'home#feedback'
  mount Ckeditor::Engine      => "/ckeditor"
  
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
