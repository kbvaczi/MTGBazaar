MTGBazaar::Application.routes.draw do
  
  # ACTIVE ADMIN SETUP ------- #
  ActiveAdmin.routes(self)
  
  # ADMIN USERS -------------- #
  devise_for :admin_users, ActiveAdmin::Devise.config
  
  # MTG CARDS ---------------- #
  match 'mtg_cards/search/' => 'mtg_cards#search', :as => 'mtg_cards_search'
  match 'mtg_cards/autocomplete_name' => 'mtg_cards#autocomplete_name', :as => 'mtg_autocomplete_name'  
  resources :mtg_cards, :only => [:index, :show] do # don't allow users to create/destroy mtg cards by only allowing index and show routes
  end



  # USERS -------------------- #
  # resources :users must be declared after devise_for because earlier declarations take precedence 
  # see http://stackoverflow.com/questions/5051487/combining-devise-with-resources-users-in-rails
  devise_for :users, :controllers => { :registrations => 'users/registrations' , :sessions => 'users/sessions' }
  resources :users, :only => [:index, :show], :controllers => { :users => "users/users"}
  resources :accounts
  
  # MISC ROUTES -------------- #
  root :to => "home#index"
  match 'about'           => 'home#about'
  match 'terms'           => 'home#terms_of_service'
  match 'privacy'         => 'home#privacy'
  match 'contact'         => 'contact#index'
  match 'contact_create'  => 'contact#create'
  
  
  
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
