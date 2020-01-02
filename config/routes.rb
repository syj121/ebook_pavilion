Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users,controllers: {sessions: 'users/sessions'}

  root "home#index"

  namespace :background do 

    #后台整体框架的首页
    get "/" => "all_out#index"
    #框架内容的首页
    get "/home" => "home#index"
    #用户管理
    resources :users

  end
end
