Rails.application.routes.draw do
  get '/quiz', to: 'static_pages#quiz'
  get '/quiz/submit', to: 'static_pages#submit'
  get '/home', to: 'static_pages#home'
  root 'static_pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
