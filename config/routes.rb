require 'sidekiq/cron/web'
require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  namespace :v1 do
    post '/auth', to: 'authentication#authenticate'
    post '/refresh', to: 'authentication#refresh_token'
    post '/logout', to: 'authentication#logout'

    namespace :admin do
      resources :users, only: %i[create update]
      resources :tokens, only: [] do
        collection do
          post 'black_list', to: 'tokens#black_list'
        end
      end
    end

    namespace :users do
      post 'verify/:token', to: 'verifications#create', as: :verify

      scope :passwords do
        patch '/', to: 'passwords#update', as: :password_update
        post '/reset', to: 'passwords#reset', as: :password_reset
        delete '/reset/:token/cancel', to: 'passwords#cancel', as: :password_reset_cancel
      end
    end

    resources :customers, only: [ :create, :update, :destroy, :show ]
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
  mount Sidekiq::Web => '/sidekiq'
end
