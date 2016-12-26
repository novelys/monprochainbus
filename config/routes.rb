Rails.application.routes.draw do
  resources :stops do
    resources :lines
  end

  resources :lines

  mount_ember_app :frontend, to: "/"
end
