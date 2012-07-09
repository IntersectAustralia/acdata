class PagesController < ApplicationController
  def home
    if !current_user.blank?
      redirect_to projects_path
    end
  end

  def routing_error
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

end
