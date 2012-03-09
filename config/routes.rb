MTGBazaar::Application.routes.draw do

  # ACTIVE ADMIN SETUP ------- #
  ActiveAdmin.routes(self)
  
  # ADMIN USERS -------------- #
  devise_for :admin_users, ActiveAdmin::Devise.config
 
 
  # SHOPPING CART ------------- #
  
  
  
  # MTG ----------------------- #
  namespace :mtg do
  
    resources :listings, :except => [:index, :show ] do
#      get  "listing" => "listings#new",    :on => :member
#      post "listing" => "listings#create", :on => :member
#      get  "listings/:id" => "listings#edit", :as => 'edit_listing', :on => :collection
#      put  "listings/:id" => "listings#update", :as => 'update_listing', :on => :collection

#      delete  "listings/:id" => "listings#delete", :as => 'delete_listing', :on => :collection
      post ":id" => "carts#add_mtg_card_to_cart", :as => 'add_to_cart', :on => :collection
    end
    resources :cards, :only => [:index, :show] do # don't allow users to create/destroy mtg cards by only allowing index and show routes
      get  "autocomplete_name", :on => :collection
      get  "search", :as => 'search', :on => :collection  # can't figure out how to send autocorrect click link via post so we need get too for now
      post "search", :as => 'search', :on => :collection      
    end

  end
  
  # USERS -------------------- #
  # resources :users must be declared after devise_for because earlier declarations take precedence 
  # see http://stackoverflow.com/questions/5051487/combining-devise-with-resources-users-in-rails
  
  get 'users/listings' => 'users#display_current_listings', :as => 'user_current_listings'
  get 'users/deposit' => 'users#new_account_deposit', :as => 'new_account_deposit'
  post 'users/deposit' => 'users#create_account_deposit', :as => 'create_account_deposit'
  get 'users/withdraw' => 'users#new_account_withdraw', :as => 'new_account_withdraw'
  post 'users/withdraw' => 'users#create_account_withdraw', :as => 'create_account_withdraw'
  get 'users/account' => 'users#show_account_info', :as => 'show_account_info'
  get 'users/cart' => 'users#show_cart', :as => 'show_cart'
  devise_for :users, :controllers => { :registrations => 'users/registrations' , :sessions => 'users/sessions' }
  resources :users, :only => [:index, :show], :controllers => { :users => "users/users"} do
    get :autocomplete_user_username, :on => :collection
  end
  
  resources :accounts

  
  # MISC ROUTES -------------- #
  root :to => "home#index"
  match 'feedback'        => 'home#feedback'
  match 'about'           => 'home#about'
  match 'terms'           => 'home#terms_of_service'
  match 'privacy'         => 'home#privacy'
  match 'contact'         => 'contact#index'
  match 'contact_create'  => 'contact#create'
  match 'help'            => 'home#help'
  
  
  
  # RAILS COMMENTS ----------- #
  
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
