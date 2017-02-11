Rails.application.routes.draw do

  get 'organizations/new'
  get 'user_organizations'      =>    'organizations#user_organizations'

  # devise routes for authentication
  devise_for :users

  # define the index route
  root to: "pages#dashboard"

  # define the profile routes, linked to the users controller
  resources :profile, :controller => 'users'

  # define the jobs resources
  resources :jobs, only: [:show, :edit, :update, :destroy] do
    # within the jobs routes, route to job applications
<<<<<<< HEAD
    resources :job_applications, :controller => 'jobs/job_applications'
=======
    # resources :job_applications
  end


  resources :organizations do
    resources :jobs, only: [:new, :create]
>>>>>>> master
  end

  resources :job_applications

  # route to job postings
  resources :job_postings do
    member do
      get 'approve'
      get 'withdraw'
    end
  end
end
