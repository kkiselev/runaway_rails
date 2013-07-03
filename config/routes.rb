Runaway::Application.routes.draw do

  match 'register' => 'api#register', :via => :post
  match 'auth' => 'api#auth', :via => :post

  match 'game/:game_id' => 'game#show', :via => :get, :as => :game
  match 'game/:game_id/edit' => 'game#edit', :via => :get
  match 'game/:game_id' => 'game#update', :via => :put, :as => :new_game
  match 'game/:game_id' => 'game#update', :via => :put, :as => :update_game

  match 'game/list' => 'api#games_list', :via => :get
  match 'game/:game_id/join' => 'api#join_game', :via => :post
  match 'game/:game_id/change_location' => 'api#change_location', :via => :post
  match 'game/:game_id/locations' => 'api#locations', :via => :get
  match 'game/:game_id/take_treasure' => 'api#take_treasure', :via => :post

  match '/:error_code' => "errors#handle"

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
  # match ':controller(/:action(/:id))(.:format)'
end
