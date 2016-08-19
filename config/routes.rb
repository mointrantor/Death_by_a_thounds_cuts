ParseRailsBoilerplate::Application.routes.draw do
  get "log_in" => "sessions#new", as: "log_in"
  get "log_out" => "sessions#destroy", as: "log_out"
  get "sign_up" => "users#new", as: "sign_up"

  resources :sessions

  resources :users do
    collection do
      match :manage, via: [:get, :post]
    end
    member { get :assign_projects }
  end
  
  resources :projects do
    member do
      get :archive
    end
  end
  
  resources :issues do
  	collection do
  		get :fetch_issue, :pdf_report, :report, :fetch_issue_report, :sample_issues_csv
      post :upload_issues
  	end
  end

  resources :comments

  namespace :api do
    resources :mailers do
      collection do
        post :send_mail
      end
    end
  end

  root to: "issues#index"
end