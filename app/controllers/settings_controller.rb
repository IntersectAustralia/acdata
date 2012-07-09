class SettingsController < ApplicationController

  load_and_authorize_resource :settings

  def edit_handles
    authorize! :edit_handles, Settings
    @settings = Settings.instance

  end

  def update_handles

    @settings = Settings.instance
    if @settings.update_attributes(params[:settings])
      redirect_to admin_users_path, :notice => "Dataset handles have been configured successfully"

    else
      render :edit_handles
    end

  end

  def edit_slide_guidelines
    authorize! :edit_slide_guidelines, Settings
    @settings = Settings.instance

  end

  def update_slide_guidelines
    authorize! :update_slide_guidelines, Settings

    @settings = Settings.instance
    if @settings.update_attributes(params[:settings])
      redirect_to admin_users_path, :notice => "Slide scanning guidelines have been configured successfully"

    else
      render :edit_slide_guidelines
    end
  end

  def edit_fluorescent_labels
    authorize! :edit_fluorescent_labels, Settings
    @settings = Settings.instance

  end

  def update_fluorescent_labels
    authorize! :update_fluorescent_labels, Settings

    @settings = Settings.instance
    if @settings.update_attributes(params[:settings])
      redirect_to admin_users_path, :notice => "Fluorescent labels have been configured successfully"

    else
      render :edit_fluorescent_labels
    end
  end

  def edit_slide_scanning_email
    authorize! :edit_slide_scanning_email, Settings
    @settings = Settings.instance

  end

  def update_slide_scanning_email
    authorize! :update_slide_scanning_email, Settings

    @settings = Settings.instance
    if @settings.update_attributes(params[:settings])
      redirect_to admin_users_path, :notice => "Slide scanning email has been configured successfully"

    else
      render :edit_slide_scanning_email
    end
  end


end
