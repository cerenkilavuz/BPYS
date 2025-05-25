Rails.application.routes.draw do
  
  devise_scope :user do
    root to: "devise/sessions#new"
  end

  devise_for :users, controllers: {
  registrations: 'users/registrations'
  }

  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard                        # Grupları Yönet
    resources :advisors , only: [:new, :create, :destroy]                         # Danışman Ekle (CRUD için)
    resource :system_setting, only: [:edit, :update] 

    resource :setting, only: [:edit, :update, :show] do
      get :export_unassigned_students  
      post :email_unassigned_students 
      post :random_group_students 
      patch :update_group_quota 
    end

    resource :project_setting, only: [:edit, :update] do
      post :assign_random_projects
      patch :rename_groups
      get :export_groups_to_csv
    end

    resources :allowed_students, only: [:new, :destroy,] do
      collection do
        post :import_csv
      end
    end

  end

  namespace :advisor do
    resource :password, only: [:edit, :update], controller: 'passwords'
    get "dashboard", to: "dashboard#index", as: :dashboard
    get 'projects', to: 'projects#dashboard'
    get 'projects/manage', to: 'projects#manage'
    get 'groups', to: 'groups#index'
    
    resources :projects do
      collection do
        get :requests  
      end
    end
     
      resources :project_requests do
        member do
          patch :accept
          patch :reject
        end
      end
      
      resources :project_proposals, only: [:index] do
        member do
          patch :accept
          patch :reject
        end
      end
    resources :groups, only: [:new, :create, :edit, :update, :destroy]
  end
  
  
  namespace :student do
    get "dashboard", to: "dashboard#index"
  
    resources :groups, only: [:index, :new, :create, :show, :destroy] do
      resources :group_members, only: [:create, :destroy]
    end
  
    resources :projects, only: [:index] do
      resources :project_requests, only: [:new, :create]
  
      collection do
        get "published", to: "projects#published", as: :published
        get "proposals", to: "projects#proposals", as: :proposals
      end
    end

    resources :project_proposals, only: [:new, :create]
  end
end 