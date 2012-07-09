class ApplicationController < ActionController::Base
  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  protect_from_forgery

  # catch access denied and redirect to the home page
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    respond_to do |format|
      format.json {
        render :json => { "error" => exception.message }, :status => :unauthorized
      }
      format.html {
        flash[:alert] = exception.message
        redirect_to projects_path
      }
    end
  end

  rescue_from ActionView::MissingTemplate do |exception|
    Rails.logger.error exception
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    Rails.logger.error exception
    respond_to do |format|
      format.json {
        render :json => { "error" => 'Not found' }, :status => 404
      }
      format.html {
        flash[:alert] = exception.message
        redirect_to projects_path
      }
    end
  end

  protected
  def projects_and_memberships
    return unless user_signed_in?

    @projects = current_user.projects.includes(:experiments => {:samples => :datasets}, :samples => :datasets).name_ordered
    @memberships = current_user.project_memberships.includes(:experiments => {:samples => :datasets}, :samples => :datasets).name_ordered
    @viewerships = current_user.project_viewerships.includes(:experiments => {:samples => :datasets}, :samples => :datasets).name_ordered
    @collaborations = current_user.project_collaborations.includes(:experiments => {:samples => :datasets}, :samples => :datasets).name_ordered

  end

end
