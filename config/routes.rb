Rails.application.routes.draw do  
  ### Invitations routes
  get "/join", to: "invitations#join"
  post "/join", to: "invitations#join"

  get 'invitations/:id/delete', to: 'invitations#delete', as: :delete_invitation
  resources :invitations
end