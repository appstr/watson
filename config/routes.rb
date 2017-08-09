Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: "devise_registrations", sessions: "devise_sessions"}
  root to: 'home#welcome'

  resources :users

  get '/ask_questions', to: 'questions#ask_questions', as: :ask_questions
  post '/submit_questions', to: 'questions#submit_questions', as: :submit_questions
end
