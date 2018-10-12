Rails.application.routes.draw do
  resources :trades, only: [:index] do
    collection do
      get :chart_data
    end
  end
end
