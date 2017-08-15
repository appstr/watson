Rails.application.routes.draw do
  root to: 'home#welcome'
  devise_for :users, controllers: {registrations: "devise_registrations", sessions: "devise_sessions"}
  mount ActionCable.server => '/cable'

  resources :users
  resources :rooms

  get '/ask_questions', to: 'questions#ask_questions', as: :ask_questions
  post '/submit_questions', to: 'questions#submit_questions', as: :submit_questions
end
