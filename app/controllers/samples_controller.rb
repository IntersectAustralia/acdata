class SamplesController < ApplicationController

  include ProjectZip
  include SamplesHelper

  before_filter :authenticate_user!
  before_filter :projects_and_memberships,
                :only => [:show, :edit, :create, :update, :list]

  load_and_authorize_resource :project
  load_and_authorize_resource :experiment, :through => :project
  load_and_authorize_resource :sample, :except => [:create, :new]

  protect_from_forgery :except => :create

  respond_to :js, :only => [:create]

  layout 'projects'

  def new
    authorize! :create_sample, @project
    if @experiment
      @sample = @experiment.samples.new
    else
      @sample = @project.samples.new
    end
  end

  def edit
  end

  def create
    authorize! :create_sample, @project

    if @experiment
      @sample = @experiment.samples.new(params[:sample])
    else
      @sample = @project.samples.new(params[:sample])
    end

    respond_to do |format|
      format.json {
        if @sample.save
          render :json => {:id => @sample.id}, :status => :created
        else
          render :json => {:error => @sample.errors}
        end
      }

      format.js {
        if @sample.save
          if @experiment
            @redirect_path = project_experiment_sample_url(@project, @experiment, @sample)
          else
            @redirect_path = project_sample_url(@project, @sample)
          end
        else
          @redirect_path = nil
        end
      }
    end
  end

  def show
  end

  def list
    respond_to do |format|
      format.json {
        render :json => {
            :samples => sample_list,
            :projects => Project.as_json_tree(@projects, @collaborations)
        }
      }
    end
  end

  def update
    experiment_id = params[:parent_experiment]
    @redirect_path = nil
    Sample.transaction do
      current_sample_dir = @sample.sample_path
      begin
        if experiment_id.blank?
          project = Project.find(params[:parent_project].to_i)
          authorize! :update, project
          params[:sample][:samplable] = project
        else
          experiment = Experiment.find(experiment_id.to_i)
          authorize! :update, experiment.project
          params[:sample][:samplable] = experiment
        end
        if @sample.update_attributes(params[:sample])
          # Ensure the parent is updated.
          @sample.reload
          Sample.move_sample(@sample, current_sample_dir)
          if experiment_id.blank?
            @redirect_path = project_sample_url(@sample.samplable, @sample, :anchor => "experiment_sample_#{@sample.id}")
          else
            @redirect_path = project_experiment_sample_url(@sample.samplable.project, @sample.samplable, @sample, :anchor => "experiment_sample_#{@sample.id}")
          end
        end
      rescue Exception => e
        @sample.errors.add(:base, e.message)
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    if @sample.destroy
      redirect_to projects_path, :notice => "The sample #{@sample.nav_name} has been successfully removed."
    else
      redirect_to :back, :alert => "The sample #{@sample.nav_name} could not be deleted."
    end
  end

  def download
    begin
      if @sample.has_attachments?
        zipfile = generate_project_zip(@sample)
        File.open(zipfile, 'r') do |f|
          send_data f.read, :filename => "#{@sample.name.to_filename}.zip"
        end
      else
        redirect_to sample_path(@sample), :alert => "No datasets to download from this sample."
      end
    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      redirect_to sample_path(@sample), :alert => "Cannot download sample"
    ensure
      logger.debug("Deleting zip: #{zipfile}")
      File.delete(zipfile) if zipfile
    end
  end

  private

  def sample_list
    samples = []
    (@projects + @collaborations).each do |project|
      samples = samples + project.samples + project.experiments.collect(&:samples).flatten
    end
    samples.map { |sample| sample.summary_for_api }
  end


end
