class DatasetsController < ApplicationController

  include DatasetsHelper
  include ProjectZip

  before_filter :authenticate_user!
  before_filter :projects_and_memberships, :except => [:download]

  protect_from_forgery :except => :create_and_add_attachments

  load_and_authorize_resource :sample
  load_and_authorize_resource :project
  load_and_authorize_resource :experiment
  load_and_authorize_resource :dataset, :except => [:new, :create, :create_and_add_attachments]

  respond_to :js, :only => [
      :new, :edit, :create, :update, :upload, :metadata,
      :create_and_add_attachments
  ]

  layout 'projects'

  expose(:all_instrument_classes) { Instrument.all.collect(&:instrument_class).uniq }

  def index
  end

  def show
  end

  def show_display_attachment
    instrument_file_type = params[:ift]
    display_file_path = @dataset.visual_attachment_path(instrument_file_type)
    if display_file_path.nil?
      render :status => 404
    else
      send_file display_file_path, {:disposition => 'inline'}
    end
  end

  def edit
    @instrument_class = @dataset.instrument.instrument_class
    @instrument_id = @dataset.instrument_id
  end

  def new
    authorize! :create_dataset, @sample
    @dataset = @sample.datasets.new
  end

  def save_sample_select
    # next button is disabled if nothing is selected, so it should always have a sample.
    @sample = Sample.find(params[:dataset][:sample_id])
    @dataset = @sample.datasets.new
    if @sample.samplable.is_a?(Project)
      @experiment = nil
      @project = @sample.samplable
    else

      @experiment = @sample.samplable
      @project = @experiment.project
    end

    render :new

  end

  def create_and_add_attachments
    json = params['dataset']
    if json.nil?
      head :bad_request
    else
      dataset_opts = JSON.parse(json)
      sample = Sample.find(dataset_opts['sample_id'])
      authorize! :create_dataset, sample

      dataset_name = dataset_opts['name']

      if sample.has_dataset_with_name?(dataset_name)
        render :json => {:error => "#{dataset_name} already exists"},
               :status => :conflict
        return
      end

      begin
        @dataset = build_dataset(sample, dataset_opts)
        @dataset.save!
        render :json => add_attachments(@dataset, dataset_opts, params),
               :status => :created
      rescue Exception => ex
        @dataset.destroy unless @dataset.nil?
        logger.error(ex.backtrace.join("\n"))
        render :json => {:error => ex.message}, :status => :bad_request
      end
    end
  end

  def create
    authorize! :create_dataset, @sample
    if params[:dataset]
      params[:dataset][:sample_id] = params[:sample_id]
      @dataset = @sample.datasets.new(params[:dataset])
      if @dataset.save

        @files_root = APP_CONFIG['files_root']
        @sample = @dataset.sample
        @extension_filter = @dataset.instrument.file_filter
        @upload_prompt = upload_prompt(@dataset.instrument)
        render :upload
      else
        @saved = false
      end
    end
  end

  def update
    sample_id = params[:parent_sample]
    @redirect_path = nil
    previous_dataset_dir = @dataset.dataset_path
    Dataset.transaction do
      begin
        if sample_id.present?
          sample = Sample.find(sample_id.to_i)
          authorize! :update, sample
          params[:dataset][:sample] = sample
        end
        if @dataset.update_attributes(params[:dataset])
          # Ensure the parent is updated.
          @dataset.reload
          Dataset.move_dataset(@dataset, previous_dataset_dir)
          if params[:instrument]
            #coming from editing a newly created dataset
            @sample = @dataset.sample
            @extension_filter = @dataset.instrument.file_filter
            @upload_prompt = upload_prompt(@dataset.instrument)
            render :upload

          else
            @redirect_path = get_dataset_path(@dataset)

          end
        end
      rescue Exception => e
        @dataset.errors.add(:base, e.message)
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
        raise ActiveRecord::Rollback
      end
    end
  end

  def upload
    @from_show_page = request.referrer.include?("#{get_dataset_path(@dataset)}")

    if params[:file_type]

      instrument_file_types = InstrumentFileType.find_all_by_name(params[:file_type].split("/"))
      @extension_filter = instrument_file_types.map { |file_type| file_type.filter }.join('; ')
      @upload_prompt = "Select a file of type: #{params[:file_type]}"

    else
      @upload_prompt = "Select files or folders to upload"

    end

  end

  def metadata
    @from_show_page = request.referrer.include?("#{get_dataset_path(@dataset)}")

  end

  def download
    begin
      zipfile = generate_zip(@dataset.dataset_path, @dataset.name.to_filename)
      File.open(zipfile, 'r') do |f|
        send_data f.read, :filename => "#{@dataset.name.to_filename}.zip"
      end
    rescue Exception => e
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      redirect_to projects_path, :alert => "Cannot Download Dataset"
    ensure
      logger.debug("Deleting zip: #{zipfile}")
      File.delete(zipfile)
    end
  end

  def destroy
    @dataset = Dataset.find(params[:id])
    return_path = @dataset.sample.samplable.is_a?(Project) ? project_sample_path(@dataset.sample.samplable, @dataset.sample) : project_experiment_sample_path(@dataset.sample.samplable.project, @dataset.sample.samplable, @dataset.sample)
    if @dataset.destroy
      redirect_to return_path, :notice => params[:new] ? "The dataset creation process was cancelled." : "The dataset was successfully deleted!"
    else
      redirect_to :back, :alert => "The dataset #{@dataset.name} could not be deleted."
    end
  end

  private
  def build_dataset(sample, dataset_opts)
    instrument = Instrument.find(dataset_opts['instrument_id'])
    sample.datasets.new(
        :name => dataset_opts['name'],
        :sample => sample,
        :instrument => instrument)
  end

  def add_attachments(dataset, dataset_opts, params)
    file_list = dataset_opts['files']
    attachment_builder = AttachmentBuilder.new(params, APP_CONFIG['files_root'], DatasetRules)
    result = attachment_builder.build(dataset, file_list)

    if (dataset_opts.include?('metadata'))
      dataset_opts['metadata'].each do |key, value|
        dataset.add_metadata(key, value, {:supplied => true})
      end
    end
    result
  end

end
