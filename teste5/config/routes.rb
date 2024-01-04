# config/routes.rb
Rails.application.routes.draw do
  get 'pages/home'
  namespace :api do
    post 'proposals/organize_conference', to: 'proposals#organize_conference'
  end
  root 'pages#home'
  post '/upload_proposals', to: 'pages#upload_proposals'

end



