Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: "devise_registrations", sessions: "devise_sessions"}
  root to: 'home#welcome'

  resources :users
end
