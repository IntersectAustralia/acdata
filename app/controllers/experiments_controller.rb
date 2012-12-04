class ExperimentsController < ApplicationController

  include ProjectsHelper
  include ProjectZip

  respond_to :js, :only => [:new, :edit, :create, :update]

  before_filter :authenticate_user!
  before_filter :projects_and_memberships, :only => [:new, :show, :edit, :create, :update, :list]

  load_and_authorize_resource :project
  load_and_authorize_resource :experiment, :only => [:download, :list]
  load_and_authorize_resource :experiment,
                              :through => :project,
                              :except => [:list, :download]

  layout 'projects'

  def new
  end

  def edit
  end

  def create

    @experiment = Experiment.new(params[:experiment])

    if @experiment.save
      @redirect_path = project_experiment_url(@experiment.project, @experiment, :anchor => "experiment_#{@experiment.id}")
      flash[:notice] = 'The experiment was successfully added.'

    else
      @redirect_path = nil
    end
  end

  def show
  end

  def list
    respond_to do |format|
      format.json {
        render :json => {
            :experiments => experiment_list,
        }
      }
    end
  end

  def update
    @redirect_path = nil
    current_exp_dir = @experiment.experiment_path
    Experiment.transaction do
      begin
        if @experiment.update_attributes(params[:experiment])
          # Ensure the project relationship is updated
          @experiment.reload
          Experiment.move_experiment(@experiment, current_exp_dir)
          @redirect_path = project_experiment_url(@experiment.project, @experiment)
          @scroll_anchor =  "experiment_#{@experiment.id}"
          flash[:notice] = 'The experiment was successfully updated.'
        end
      rescue Exception => e
        @redirect_path = nil
        @experiment.errors.add(:base, e.message)
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
        raise ActiveRecord::Rollback
      end
    end

  end

  def destroy
    if @experiment.destroy
      redirect_to projects_path, :notice => "The experiment #{@experiment.name} has been successfully removed."
    end
  end

  def collect_document
    if @experiment.document.present?
      send_file @experiment.document.path, :filename => @experiment.document.original_filename
    else
      redirect_to project_experiment_path(@experiment.project, @experiment), :alert => "The experiment #{@experiment.name} has no supplementary document."
    end
  end

  def delete_document
    @experiment.document.destroy
    @experiment.document = nil
    @experiment.save
    flash[:notice] = "The related document has been successfully removed."
  end

  def sample_select
    @dataset = Dataset.new
    @samples = @experiment.samples
    render :template => 'shared/sample_select'
  end

  def download
    begin
      if has_attachments?(@experiment)

        zipfile = generate_project_zip(@experiment)
        File.open(zipfile, 'r') do |f|
          send_data f.read, :filename => "#{@experiment.name.to_filename}.zip"
        end
      else
        redirect_to project_experiment_path(@experiment.project, @experiment), :alert => "No datasets to download from this experiment."
      end
    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      redirect_to project_experiment_path(@experiment.project, @experiment), :alert => "Cannot download experiment"
    ensure
      logger.debug("Deleting zip: #{zipfile}")
      File.delete(zipfile) if zipfile
    end
  end

  private


  def experiment_list
    experiments = []
    (@projects + @collaborations).each do |project|
      experiments << project.experiments
    end
    Rails.logger.debug(experiments.inspect)
    experiments.flatten.map { |experiment| experiment.summary_for_api(:samples => false) }
  end

end

