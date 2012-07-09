class AttachmentsController < ApplicationController

  before_filter :authenticate_user!

  load_and_authorize_resource

  def upload
    dataset = get_dataset(params)
    authorize! :manage, dataset

    json_string = params[:dirStruct]
    file_list = ActiveSupport::JSON.decode(json_string)

    attachment_builder = AttachmentBuilder.new(params, APP_CONFIG['files_root'], DatasetRules)
    result = attachment_builder.build(dataset, file_list)

    respond_to do |format|
      format.json { render :json => result }
    end
  end

  def verify_upload
    dataset = get_dataset(params)
    authorize! :manage, dataset

    # TODO: pull out
    filenames = []

    file_tree_array = ActiveSupport::JSON.decode(params[:dirStruct])
    file_tree_array.each do |file_tree|
      if file_tree.keys.include?('folder_root')
        filenames << file_tree['folder_root']
      else
        filenames << get_filename_from_tree(file_tree)
      end

    end
    # END: pull out

    result = DatasetRules.verify_from_filenames(dataset, filenames)

    respond_to do |format|
      format.json { render :json => result }
    end
  end

# GET attachments/1 - attachment
# GET attachments/1/preview - thumbnail

  def show
    @attachment = Attachment.find(params[:id])
    if FileTest.directory?(@attachment.path)
      begin
        zipfile = @attachment.make_zip
        File.open(zipfile, 'r') do |f|
          send_data f.read, :filename => "#{@attachment.filename}.zip"
        end
      rescue Exception => e
        logger.error(e.message)
        logger.error(e.backtrace.join("\n"))
      ensure
        File.delete(zipfile) if zipfile
      end
    else

      #Internet Explorer doesn't handle unicode filenames
      sanitise = request.env['HTTP_USER_AGENT'].downcase.index('msie').present?
      filename = sanitise ? @attachment.sanitise_for_ie : @attachment.filename
      send_file @attachment.path, :filename => filename
    end
  end

  def preview
    @attachment = Attachment.find(params[:id])
    unless @attachment.preview_file.blank?
      send_file @attachment.preview_file_path, :type => @attachment.preview_mime_type, :disposition => 'inline'
    end
  end

  def download
    show
  end

  def show_inline
    send_file @attachment.path, { :disposition => 'inline'}
  end

  def destroy
    attachment = Attachment.find(params[:id])
    dataset = attachment.dataset
    return_path = get_return_path(dataset, :tab => "tabs-files")

    if attachment.destroy
      logger.debug("Removing Attachment #{attachment.path}")
      FileUtils.rm_rf attachment.path
      if attachment.preview_file
        logger.debug("Removing Preview #{attachment.preview_file_path}")
        FileUtils.rm_rf attachment.preview_file_path
      end
      redirect_to return_path, :notice => "The file was successfully deleted"
    else
      redirect_to :back, :alert => "The attachment #{attachment.filename} could not be deleted."
    end
  end

  private

  def get_filename_from_tree(file_tree)
    file_key = file_tree.keys.find { |key| key.starts_with? "file_" }
    file_tree[file_key]
  end

  def get_dataset(params)
    dest_dir = params[:destDir]
    dataset_id = dest_dir.match(/(\d+)$/)[0]
    Dataset.find_by_id(dataset_id)
  end

  def get_return_path(dataset, options = nil)
    if dataset.sample.samplable.is_a?(Project)
      project_sample_dataset_path(
          dataset.sample.samplable, dataset.sample, dataset, options)
    else
      project_experiment_sample_dataset_path(
          dataset.sample.samplable.project,
          dataset.sample.samplable,
          dataset.sample,
          dataset, options)
    end
  end

end
