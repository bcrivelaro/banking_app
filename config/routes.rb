# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }

  devise_scope :user do
    authenticated :user do
      root 'transactions#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  resources :transactions, only: :index
  resources :transfers, only: %i[new create]
end
