# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :novels, only: [] do
        resources :characters, only: %i[index show create update destroy]
        resources :world_settings, only: %i[index show create update destroy]
        resources :character_relationships, only: %i[index show create update destroy]
        resources :foreshadowings, only: %i[index show create update destroy] do
          member do
            patch :resolve
            patch :abandon
          end
        end
        resources :character_states, only: %i[index show create update destroy]
        resources :relationship_logs, only: %i[index show]
        get :context_summary, to: "context_summaries#show"
      end
    end
  end
end
