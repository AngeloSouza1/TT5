# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    post 'proposals/organize_conference', to: 'proposals#organize_conference'
  end


end



