Rails.application.routes.draw do
  root "dashboard#index"

  get "up" => "rails/health#show", :as => :rails_health_check

  namespace :api do
    namespace :v1 do
      post "test_runs", to: "test_runs#create"
    end
  end

  resources :projects do
    member do
      get "metrics"
    end
  end

  post "generate_sample_data", to: "dashboard#generate_sample_data"
  post "clear_sample_data", to: "dashboard#clear_sample_data"
end
