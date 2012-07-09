class ActivitiesController < ApplicationController

  load_and_authorize_resource :project, :except => [:list_for_codes, :validate_rda_grant]
  load_and_authorize_resource :activity, :through => :project,
                              :singleton => true,
                              :except => [:list_for_codes, :validate_rda_grant]
  load_and_authorize_resource :activity, :only => [:list_for_codes, :validate_rda_grant]

  def new

  end

  def create

    Activity.transaction do
      begin
        @activity.save!
        AndsHandle.assign_handle(@activity) unless @activity.from_rda?
        @successful = true
      rescue
        @successful = false
        raise ActiveRecord::Rollback

      end
    end

    if @successful
      @redirect_path = project_path(@project)
      flash[:notice] = "Activity record was successfully created."

    else
      @redirect_path = nil

    end


  end

  def edit

  end

  def update

    Activity.transaction do
      begin
        @activity.update_attributes!(params[:activity])
        AndsHandle.assign_handle(@activity) unless @activity.from_rda?
        @activity.publish if !@activity.from_rda? and @activity.published?

        @successful = true
      rescue
        @successful = false
        raise ActiveRecord::Rollback

      end
    end

    if @successful
      @redirect_path = project_path(@project)
      flash[:notice] = "Activity record was successfully updated."

    else
      @redirect_path = nil

    end

  end

  def select_grant_type
    if @project.published?
      flash.now[:alert] = "Note: Republishing the project is required to include a newly assigned grant"
    end
  end

  def select_rda_grant
    @activity ||= Activity.new(:project => @project)
    @activity.from_rda = true
    @activity.published = true
    @rda_grant = @activity.rda_grant
  end


  def list_for_codes
    respond_to do |f|
      f.json do
        render :json => ForCode.generate_ac_options(params[:term])
      end
    end
  end

  def validate_rda_grant
    respond_to do |f|
      f.json do
        rda_grant = RdaGrant.find_by_grant_id(params[:grant_id])
        if rda_grant
          render :json => rda_grant.attributes

        else
          render :json => nil
        end
      end
    end
  end
end
