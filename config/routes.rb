Rails.application.routes.draw do
  root 'trades#index'
  resources :trades, only: [:index] do
    collection do
      get :chart_data
    end
  end
end
