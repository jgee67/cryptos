Rails.application.routes.draw do
  root 'trades#index'
  resources :trades, only: [:index] do
    collection do
      get :binance_chart_data
      get :bitmex_chart_data
      post :export
    end
  end
end
