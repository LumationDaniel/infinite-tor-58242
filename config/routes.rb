Pickem::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  resource :fb, controller: :facebook_canvas, only: [] do
    resources :requests, controller: :facebook_apprequests, only: [:index]
  end

  namespace :fb do
    with_options(controller: :games, via: [:get, :post]) do |games|
      games.match '/', action: :upcoming
      games.match 'games/completed', action: :completed
      games.match 'games/picks', action: :picks
      [:upcoming, :completed, :picks].each do |action|
        games.match "games/#{action}/:id", action: action
      end
    end

    with_options(controller: :leaderboards) do |leaderboards|
      leaderboards.match '/leaderboards', action: :index
      leaderboards.match '/leaderboards/:id', action: :show
    end

    resources :challenges, only: [:index, :show, :update] do
      collection do
        post '/', action: :index
      end
      member do
        post '', action: :show
        post 'accept'
        post 'decline'
      end
    end
  end

  scope "sites/:site", module: 'sites' do
    namespace :fb, module: 'facebook' do
      with_options(controller: :questions, via: [:get, :post]) do |questions|
        questions.match '/', action: :upcoming
        questions.match 'questions/completed', action: :completed
        questions.match 'questions/picks', action: :picks
        [:upcoming, :completed, :picks].each do |action|
          questions.match "questions/#{action}/:id", action: action
        end
      end
      with_options(controller: :leaderboards) do |leaderboards|
        leaderboards.match 'leaderboards', action: :index
      end
      resources :answers, only: :update
    end
  end

  match '/facebook' => redirect(FB[:canvas_page]), as: :facebook

  resources :unsubscribes, only: [:create, :destroy] do
    collection do
      get '/', action: :create
    end
  end
  resources :alerts, only: :destroy

  namespace :mobile do
    constraints :subdomain => "m" do
    end

    get '/' => 'games#upcoming'
  end

  match '/style_guide' => 'welcome#style_guide'
  match '/_d/:action', controller: :debug

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  resources :entries, controller: :pickem_entries, only: :update

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

  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
