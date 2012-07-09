require 'unsw_idm'

class UserRegistersController < Devise::RegistrationsController

  prepend_before_filter :authenticate_scope!, :only => [:edit, :add_eln_blog, :remove_eln_blog, :update, :destroy] #, :edit_password, :update_password, :feedback, :send_feedback]

  respond_to :js, :only => [:validate_blog]

  def after_inactive_sign_up_path_for(resource)
    root_path
  end

  # Override the create method in the RegistrationsController
  def create
    # Find them in LDAP

    authenticated = false
    user_details = get_user_details
    if user_details.nil?
      params[resource_name] = {}
      set_flash_message :entry_alert, :invalid
    else
      # Do we have this user already?
      user = User.find_by_login(params[resource_name][:login])
      if !user.nil?
        if user.approved?
          set_flash_message :notice, :existing_account
        elsif user.pending_approval?
          set_flash_message :notice, :pending
        elsif user.rejected?
          set_flash_message :entry_alert, :permanently_rejected
        else
          set_flash_message :entry_alert, :generic_problem
        end
        redirect_to root_path
        return
      end

      # Override email from LDAP with user supplied email
      if !params[resource_name][:email].blank?
        user_details[:email] = params[resource_name][:email]
      end
      params[resource_name] = params[resource_name].merge(user_details)
      authenticated = true
    end

    build_resource

    if authenticated and resource.save
      begin
        Notifier.notify_superusers_of_access_request(resource).deliver
        Notifier.notify_user_of_sent_request(resource).deliver
        set_flash_message :notice, :registered
      rescue Net::SMTPFatalError => smtp_error
        logger.error(smtp_error.message)
        set_flash_message :error, :notification_error
      end
      redirect_to root_path
    else
      render_with_scope :new
    end
  end

  def get_authentication_token
    if current_user.nil?
      head :unauthorized
    else
      current_user.reset_authentication_token!
      render :json => current_user.authentication_token.to_json
    end
  end

  def update

    #TODO reject duplicate entries

    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      redirect_to projects_path
    else
      clean_up_passwords(resource)
      render_with_scope :edit
    end
  end

  def edit_password
    set_flash_message :entry_alert, :change_password
    redirect_to root_path
  end

  def update_password
    set_flash_message :entry_alert, :change_password
    redirect_to root_path
  end

  private

  def get_user_details

    details = nil
    if params[resource_name]
      ldap = UNSW::IDM::LDAPConnector.new(ENV['RAILS_ENV'])
      begin
        details = ldap.get_user_details(
            params[resource_name][:login], params[resource_name][:password])
      rescue Net::LDAP::LdapError => ldap_exception
        set_flash_message :entry_alert, :generic_problem
        logger.error(ldap_exception.message)
      rescue UNSW::IDM::LDAPException => ldap_exception
        if ldap_exception.message == 'Invalid Credentials'
          p "blah"
          set_flash_message :entry_alert, :invalid
        else
          set_flash_message :entry_alert, :generic_problem
          logger.error(ldap_exception.message)
        end
      end
    end
    details
  end

end
