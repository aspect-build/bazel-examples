# frozen_string_literal: true

require_relative "application"

Rails.application.initialize!

# Load routes explicitly for Bazel sandbox compatibility
Rails.application.routes.draw do
  resources :items, only: [:index, :show, :create]
  get "/health", to: "health#show"
end
