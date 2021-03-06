OusdCommunityPartners::Application.routes.draw do
  devise_for :users, path: "auth", class_name: 'User', controllers: { registrations: "users/registrations" }

  resources :users do
    member do
      post :send_invitation
    end

    resources :user_roles, only: [:new, :create, :destroy], as: :roles
  end

  devise_scope :user do
    get '/sign_in' => 'devise/sessions#new'
    get '/sign_out' => 'devise/sessions#destroy'
    get '/sign_up' => 'devise/registrations#new'
  end
  

  resources :schools do
    member do
      get :primary_contact_input
    end
  end

  resources :community_programs do
    member do
      put :toggle_active
    end
  end

  resources :organizations do
    resources :program_verifications,
              controller: 'organizations/program_verifications',
              only: [:new, :create]

    member do
      get :verification
      get :primary_contact_input
    end
  end
  
  resources :quality_elements do
    member do
      get :service_type_inputs
    end
  end

  resources :service_types

  resources :api do
    collection do
      get :community_programs
      get :school_hierarchy
      get :schools
      get :school_sub_areas
    end
  end

  resources :visualizations do
    collection do
      get :school_hierarchy
    end
  end

  namespace :admin do
    resources :dashboard, only: :index
  end

  if defined?(Peek) && Rails.env.development?
    mount Peek::Railtie => '/peek'
  end

  root to: "schools#index"
end
