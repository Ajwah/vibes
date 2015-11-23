Rails.application.routes.draw do
  root 'welcome#index'
  get 'immediate/search' => 'vibes#immediate'
  get 'gradual/search' => 'vibes#gradual'
  get 'cached/search' => 'vibes#cached'

  mount Resque::Server, :at => "/resque"
end
