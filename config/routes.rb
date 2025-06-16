Rails.application.routes.draw do
  get 'payments/create'
  get 'payments/callback'
  get "/healthcheck", to: proc { [200, {}, ["Ok"]] }
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :account_block do
    resources :accounts do
      collection do
        put :verify_account 
        post :resend_verification_email
      end
    end
    get 'show_user_with_token', to: 'accounts#show_user_with_token'
    get 'catalogues', to: 'accounts#index'
    put 'edit_profile', to: 'accounts#edit_profile'
    put 'edit_profile_skill', to: 'accounts#edit_profile_skill'
    put 'edit_profile_picture', to: 'accounts#edit_profile_picture'
    put 'edit_cover_photo', to: 'accounts#edit_cover_photo'
    delete 'delete_sub_category', to: 'accounts#delete_sub_category'
    get '/india_states', to: 'accounts#states'

    post 'upload_media', to: 'account_media#upload_media'
    put 'portfolio_links', to: 'account_media#portfolio_links'
    put 'social_media_links', to: 'account_media#social_media_links'
    delete 'delete_profile_image', to: 'account_media#delete_profile_image'
    delete 'delete_cover_image', to: 'account_media#delete_cover_image'
    resources :account_media, only: [] do
      member do
        delete :delete_specific_media
        patch :update_specific_media
      end
    end
  end
  namespace :bx_block_razorpay do 
    resources :payments, only: [] do
      collection do
        post :create_subscription
      end
    end
  end

  post '/bx_block_razorpay_webhook/razorpay', to: 'bx_block_razorpay_webhook/razorpay_webhooks#receive'

  namespace :bx_block_forgot_password do 
    post 'send_verification_code', to: 'otps#send_verification_code'
    post 'verify_otp', to: 'otps#verify_otp'
    post 'two_factor_otp_verify', to: 'otps#two_factor_otp_verify'
    post 'reset_password', to: 'passwords#reset_password'
    post 'change_password', to: 'passwords#change_password'
  end


  namespace :admin do
    resources :payments do
      collection do
        post :export_csv
      end
    end
  end

  namespace :bx_block_contact_us do
    resources :contacts
  end

  namespace :bx_block_profile do 
    resources :user_profiles
  end 
  
  namespace :bx_block_profile do 
    resources :user_skills
  end

  namespace :bx_block_profile do 
    resources :user_careers
  end 

  namespace :bx_block_profile do
    resources :user_educations
  end 

  namespace :bx_block_login do 
    resources :logins 
  end

  namespace :bx_block_language do
    resources :user_languages
  end


  namespace :bx_block_terms_and_conditions do
    resources :terms_and_conditions, only: [:index]
    get "privacy_policy", to: 'terms_and_conditions#privacy_policy'
    get "about_us", to: 'terms_and_conditions#about_us'
  end

  namespace :bx_block_settings do
    resources :settings, only: [:index] do
      collection do
        patch :toggle_two_factor
        patch :update_notification
        patch :update_account_profile
        patch :update_account_email
        post :verify_email_otp
        post :update_password
      end
    end
  end

  namespace :bx_block_content_management do 
    resources :content_managements
    get 'landing_page', to: 'content_managements#landing_page'
    get 'testimonials', to: 'content_managements#testimonials'
    post 'subscribe_email', to: 'content_managements#subscribe_email'
  end

  namespace :bx_block_categories do 
    resources :category_lists
  end

  namespace :bx_block_custom_user_subs do 
    resources :subscriptions
  end 

  namespace :bx_block_order_management do 
    resources :sub_scription_orders, only: [:index]
    get '/sub_scription_orders/user_current_plan', to: 'sub_scription_orders#user_current_plan'
    get 'user_all_plans', to: 'sub_scription_orders#user_all_plans'
  end

  namespace :bx_block_chat do
    resources :chats, only: [:index] do 
      collection do 
        post :send_message
        get :history
        get :fetch_messages
        get :get_user_conversation
        post :mark_as_delivered
        post :mark_as_read
        post :block_user
        delete :unblock_user
        delete :delete_message
        get :search_conversations
        get :chat_history
        delete :delete_conversation
      end
    end
    resources :messages, only: [:index, :create] 
  end

  namespace :bx_block_notifications do 
    resources :notifications do
      collection do
        put :read_all_notification 
      end
    end
  end

end  
