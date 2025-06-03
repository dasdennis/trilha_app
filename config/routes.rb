Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # Trails resource: only index and import (POST) actions
  resources :trails, only: [ :index ] do
    collection do
      post :import # Secure: should be protected by authentication/authorization
    end
  end

  # Mapbox proxy endpoint (should be protected by rate limiting)
  get "api/mapbox_proxy", to: "trails#proxy_mapbox"

  # Root path for the application
  root "trails#index"
end
