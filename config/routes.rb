Rails.application.routes.draw do

  namespace :webhook do
    post 'olark/:token' => 'inbound#olark', as: :olark_webhook
  end

end
