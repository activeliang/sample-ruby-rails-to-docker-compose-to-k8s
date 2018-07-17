Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'
  mount ActionCable.server => '/cable'

  get 'rooms/show'
end
