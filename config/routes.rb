Acdata::Application.routes.draw do

  devise_for :users, :controllers => {:registrations => "user_registers"} do
    #allow users to edit their own password
    get "/users/edit_password", :to => "user_registers#edit_password"
    #allow users to edit their own password
    put "/users/update_password", :to => "user_registers#update_password"
    get "/users/validate_blog", :to => "user_registers#validate_blog"
    get "/users/get_authentication_token", :to => "user_registers#get_authentication_token"

  end

  # The API
  get "/api/samples", :to => "samples#list"
  get "/api/experiments", :to => "experiments#list"
  get "/api/projects", :to => "projects#list"
  get "/api/instruments", :to => "instruments#list"
  post "/api/datasets", :to => "datasets#create_and_add_attachments"
  post "/api/samples", :to => "samples#create"
  post "/api/message"
  get "/api/keepalive"

  resource :settings, :only => [:update] do
    get :edit_handles
    put :update_handles
    get :edit_slide_guidelines
    put :update_slide_guidelines
    get :edit_fluorescent_labels
    put :update_fluorescent_labels
    get :edit_slide_scanning_email
    put :update_slide_scanning_email
  end

  resources :users, :only => [:show] do
    collection do
      get :access_requests
      get :index
      get :admin
      get :list
      get :ands_publishable_requests
    end

    member do
      get :reject
      get :reject_as_spam
      put :deactivate
      put :activate
      get :edit_role
      put :update_role
      get :edit_approval
      put :approve
    end
  end

  match 'projects/:id/remove_member/:user_id' => 'projects#remove_member', :as => :remove_member_project
  match 'projects/:id/make_owner/:user_id' => 'projects#make_owner', :as => :make_owner_project

  resources :projects do
    resources :experiments do
      resources :samples do
        resources :datasets do
          member do
            put :upload
            get :upload
            get :edit
            get :metadata
          end

        end
      end

      member do
        get :sample_select
        get :collect_document
        delete :delete_document
      end
    end

    resources :samples do
      resources :datasets do
        member do
          put :upload
          get :upload
          get :edit
          get :metadata
        end

      end
    end

    resources :ands_publishables do

      member do
        get :submit
        get :specify_related_info
        get :specify_party_info
        put :related_info_specified
        put :party_info_specified
      end
    end

    resources :activities do
      collection do
        get :select_grant_type
        get :select_rda_grant
      end
    end

    member do
      get :show_publishable_data
      get :request_slide_scanning
      get :sample_select
      get :download
      get :collect_document
      delete :delete_document
      post :leave
      post :send_slide_request

    end

    collection do
      get :slide_guidelines_pdf
    end

  end

  resources :experiments, :only => [:download] do
    member do
      get :download
    end
  end

  resources :samples, :only => [:download] do
    member do
      get :download
    end
  end

  resources :datasets, :only => [:update, :create] do
    member do
      get :show_display_attachment
      get :download
    end

    collection do
      post :save_sample_select
    end

    resources :eln_exports, :only => [:new, :update, :create, :edit]

    resources :memre_export, :only => [:new, :update, :create, :edit]
  end

  resources :activities, :only=>[] do
    collection do
      get :list_for_codes
      get :validate_rda_grant
    end
  end

  resources :ands_publishables, :only => [] do

    collection do
      get :list_for_codes
      get :list_seo_codes
      get :list_subject_keywords
      get :list_ands_parties
    end

    member do
      get :preview
      get :approve
      put :reject
      get :reject_reason
      get :download

    end
  end

  resources :attachments, :only => [:destroy, :show] do
    collection do
      post :upload
      post :verify_upload
    end
    member do
      get :download
      get :preview
      get :show_inline
      post :update_file
    end
  end

  resources :instruments do
    member do
      put :mark_unavailable
      put :mark_available
    end
  end

  root :to => "pages#home"
  get "pages/home"

# This should always be the last route
# It is here to handle routing errors
# It should match every route not already matched
# Solution taken from http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => 'pages#routing_error'
end
