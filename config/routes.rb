ConsiderIt::Application.routes.draw do
  
  resources :point_links

  root :to => "home#index"
  
  resources :options, :only => [:show] do
    resources :positions, :only => [:new, :edit, :create, :update, :show]
    resources :points, :only => [:index, :create, :update, :destroy] do 
      resources :inclusions, :only => [:create] 
    end
    resources :point_similarities, :module => :admin
    resources :comments, :only => [:index, :create]
  end

  devise_for :users, :controllers => { 
    :omniauth_callbacks => "users/omniauth_callbacks", 
    :sessions => "users/sessions", 
    :registrations => "users/registrations",
    :passwords => "users/passwords",
    :confirmations => "users/confirmations"
  }

  themes_for_rails # themes_for_rails gem routes 

  match "/theme" => "theme#set", :via => :post
  match "/home/zip" => "home#set_zipcode", :via => :post
  match "/home/pledge" => "home#take_pledge", :via => :post
  match '/home/:page' => "home#show", :via => :get, :constraints => { :page => /terms-of-use|considerit/ } 

end
