Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users,controllers: {sessions: 'users/sessions'}

  root "background/all_out#index"

  #统一管理后台
  namespace :background do 
    #后台整体框架的首页
    get "/" => "all_out#index"
    #框架内容的首页
    get "/home" => "home#index"
    #用户管理
    resources :users
    #菜单管理
    resources :menus do 
      collection do 
        get :permission_groups
        post :save_permision
      end
    end
    #角色管理
    resources :roles
  end
  #统一管理后台 background END

  #图书来源
  namespace :ebook do 
    #来源网站
    resources :web_sites
    #来源网站-图书类别
    resources :web_categories
    #抓取
    resources :snatches, only: [] do 
      collection do 
        get :book
        get :categories
      end
    end
    #来源网站-图书
    resources :web_books do 
      member do 
        get :download
      end

      #源网站图书章节
      resources :web_chapters do 
        collection do 
          get :refresh
        end
      end
    end
  end
  #图书来源 ebook END
  
  #云平台-图书管理
  namespace :cloud do
    #类别管理
    resources :categories
    #云图书管理
    resources :books
  end
  #云平台-图书管理
  
end
