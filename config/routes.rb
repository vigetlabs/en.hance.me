EnhanceMe::Application.routes.draw do

  resources :sources, :only => [:create, :show] do
    resources :montages, :only => [:create]
  end

  resources :montages, :only => [:show]

  root :to => 'sources#new'

  # need this because Rails `rescue_from` doesn't catch ActionController::RoutingError
  unless Rails.env.development?
    match '*path',  :to => 'application#render_404', :via => :all
  end

end
