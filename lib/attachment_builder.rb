class AttachmentBuilder
  require_relative 'preview_builder'

  def initialize(file_params, files_root, rules)
    @file_map = map_uploads(file_params)
    @files_root = files_root
    @verification_rules = rules
  end

  def build(dataset, file_list)

    dest_dir = File.join(@files_root, PathBuilder::Path.file_path(dataset))
    Rails.logger.debug("AttachmentBuilder.build file_list=#{file_list.inspect}")

    # Turn tree into some attributes ready to build attachments
    candidates = []
    file_list.each do |file_tree|
      attrs = process_file_or_folder(dest_dir, file_tree, dataset.instrument)
      candidates << attrs
    end

    result_list = @verification_rules.verify(candidates, dataset)

    process_attachments(result_list, dataset, dest_dir)
  end

  def process_attachments(result_list, dataset, dest_dir)
    result = {}
    result_list[:rejected].each do |attrs, reason|
      # Delete from filesystem?
      FileUtils.rm_rf(attrs[:path])
      result[attrs[:filename]] = {:status => "failure", :message => reason}
    end

    new_attachments = result_list[:verified]
    return result unless new_attachments.present?

    if !Dir.exist? dest_dir
      Rails.logger.debug("Creating folder #{dest_dir}")
      FileUtils.mkdir_p(dest_dir, :mode => default_dir_mode)
    end

    result = create_attachments(new_attachments, dataset, dest_dir, result)
  end

  def create_attachments(new_attachments, dataset, dest_dir, result)
    new_attachments.each do |attributes|
      file_path = attributes.delete(:path)
      preview_file, preview_mime_type = create_preview(file_path)
      unless preview_file.nil?
        attributes[:preview_file] = preview_file
        attributes[:preview_mime_type] = preview_mime_type
      end

      attachment = dataset.attachments.create(attributes)
      if dataset.save
        begin
          attachment.set_indelible if indelible?(dataset, attachment)
          add_metadata(dataset, attachment) if metadata_source?(dataset, attachment)
          create_visualisation(attachment) if visualisable?(dataset, attachment)
        rescue StandardError => e
          Rails.logger.error("Error occurred in parsing, deleting attachment : #{e}")
          Rails.logger.error("Error occurred in parsing: #{e.backtrace.join("\n")}")
          dataset.delete_metadata(attachment)
          attachment.destroy
          result[attributes[:filename]] = {:status => "failure", :message => "Error parsing this attachment."}
        else
          result[attributes[:filename]] = {:status => "success", :message => ""}

        end
      else
        attachment.destroy
        result[attributes[:filename]] = {:status => "failure", :message => dataset.errors[:attachments]}
      end
    end

    result
  end

  private

  def map_uploads(file_params)
    file_map = {}
    file_params.each do |key, value|
      path = value
      if value.is_a?(ActionDispatch::Http::UploadedFile) or
         value.respond_to?(:path)
        path = value.path
      end
      if File.exists?(path)
        file_map[key.to_s] = path
      end
    end
    file_map
  end

  def visualisable?(dataset, attachment)
    instrument_rule = dataset.instrument_rule
    !instrument_rule.nil? && instrument_rule.visualisable?(attachment.instrument_file_type)
  end

  def metadata_source?(dataset, attachment)
    instrument_rule = dataset.instrument_rule
    !instrument_rule.nil? && instrument_rule.metadata?(attachment.instrument_file_type)
  end

  def indelible?(dataset, attachment)
    instrument_rule = dataset.instrument_rule
    instrument_rule.nil? ? false : instrument_rule.indelible?(attachment.instrument_file_type)
  end

  def create_visualisation(attachment)
    file_type = attachment.instrument_file_type
    creator = file_type.visualisation_handler
    if creator
      Object::const_get(creator).build(attachment)
    end
  end

  def get_format(file_tree)
    file_tree.keys.include?('folder_root') ? 'folder' : 'file'
  end

  def write_files(dest_dir, file_tree)
    if get_format(file_tree) == 'folder'
      filename = file_tree['folder_root']
      create_all_folders(file_tree, dest_dir)
    else
      filename = get_filename(file_tree)
    end
    create_all_files(file_tree, dest_dir)
    filename
  end

  def process_file_or_folder(dest_dir, file_tree, instrument)

    filename = write_files(dest_dir, file_tree)

    format = get_format(file_tree)
    path = File.join(dest_dir, filename)
    instrument_file_type = InstrumentFileType.identify(path, instrument)

    attrs = {
        :filename => filename,
        :path => path,
        :format => format,
        :instrument_file_type => instrument_file_type
    }
  end

  def get_filename(file_tree)
    file_key = file_tree.keys.find { |key| key.starts_with? "file_" }
    file_tree[file_key]
  end

  def create_all_folders(file_tree, dest_dir)
    file_tree.find_all { |type, val| type.starts_with? "folder_" }.each do |folder, path|

      folder = File.join(dest_dir, path.gsub(/\\+/, "/"))

      if !Dir.exist? folder
        #Rails.logger.debug("Creating folder #{folder}")
        FileUtils.mkdir_p(folder, :mode => default_dir_mode)
      end
    end
  end

  def create_all_files(file_tree, dest_dir)
    file_list = file_tree.find_all { |type, val| type.starts_with? "file_" }
    file_list.each do |key, path|
      file_path = @file_map[key]
      upload_path = File.join(dest_dir, path.gsub(/\\+/, "/"))
      if !Dir.exist? dest_dir
        FileUtils.mkdir_p(dest_dir, :mode => default_dir_mode)
      end
      FileUtils.cp_r(file_path, upload_path)
      FileUtils.chmod(default_file_mode, upload_path) if File.file?(upload_path)
    end
  end

  # Checks to see if the extension is one of the following types (but does not test contents):
  #   GIF (.gif)
  #   JPEG (.jpg, .jpeg)
  #   PNG (.png)
  # Not supported by GD2-FFIJ gem (so workaround required):
  #   TIFF (.tif, .tiff)
  # Workaround won't work for:
  #   BMP (.bmp)

  def create_preview(path)
    preview_file, preview_mime_type =
        if PreviewBuilder.is_image?(path)
          Rails.logger.debug("#{path} is an image")
          PreviewBuilder.make_image_preview(path)
        else
          Rails.logger.debug("#{path} is NOT an image")
          nil
        end
    return preview_file, preview_mime_type
  end

  def add_metadata(dataset, attachment)
    file_parser = attachment.parser
    if file_parser
      meta_hash = file_parser.parse(attachment.path)
      meta_hash.keys.each do |key|
        next if meta_hash[key].nil?
        value = meta_hash[key]['value']
        core = (meta_hash[key].include?('core') && meta_hash[key]['core'])
        supplied = (meta_hash[key].include?('supplied') && meta_hash[key]['supplied'])
        dataset.add_metadata(key, value, {:core => core,
                                          :attachment => attachment,
                                          :supplied => supplied})
      end
    end
  end

  def default_dir_mode
    @dir_mode ||= ~File.umask & 0755
  end

  def default_file_mode(file=true)
    @file_mode ||= ~File.umask & 0644
  end

end
