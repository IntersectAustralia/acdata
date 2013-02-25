module DatasetsHelper

  def get_dataset_path(dataset, options = nil)
    if dataset.sample.samplable.is_a?(Project)
      project_sample_dataset_path(
          dataset.sample.samplable,
          dataset.sample,
          dataset, options)
    else
      project_experiment_sample_dataset_path(
          dataset.sample.samplable.project,
          dataset.sample.samplable,
          dataset.sample,
          dataset, options)
    end
  end

  def get_upload_dataset_path(dataset, options = nil)

    @sample = dataset.sample
    if @sample.samplable.is_a?(Experiment)
      upload_project_experiment_sample_dataset_path(@sample.samplable.project, @sample.samplable, @sample, dataset, options)
    else
      upload_project_sample_dataset_path(@sample.samplable, @sample, dataset, options)

    end

  end

  def get_edit_dataset_path(dataset, options = nil)

    @sample = dataset.sample

    if @sample.samplable.is_a?(Experiment)
      edit_project_experiment_sample_dataset_path(@sample.samplable.project, @sample.samplable, @sample, dataset, options)
    else
      edit_project_sample_dataset_path(@sample.samplable, @sample, dataset, options)

    end

  end

  def get_new_dataset_path(sample, options = nil)

    if sample.samplable.is_a?(Experiment)
      new_project_experiment_sample_dataset_path(sample.samplable.project, sample.samplable, sample, options)
    else
      new_project_sample_dataset_path(sample.samplable, sample, options)

    end

  end

  def get_metadata_dataset_path(dataset, options = nil)
    @sample = dataset.sample

    if @sample.samplable.is_a?(Experiment)
      metadata_project_experiment_sample_dataset_path(@sample.samplable.project, @sample.samplable, @sample, dataset, options)
    else
      metadata_project_sample_dataset_path(@sample.samplable, @sample, dataset, options)

    end
  end

  def get_eln_export_path(dataset)
    if dataset.eln_exports.present?
      eln_export = ElnExport.where(:user => current_user, :dataset => dataset).first
      if eln_export.present?
        return edit_dataset_eln_export_path(dataset, eln_export)
      end
    end
    new_dataset_eln_export_path(dataset)
  end

  def get_memre_export_path(dataset)
    if dataset.memre_export.present?
      edit_dataset_memre_export_path(dataset, dataset.memre_export)
    else
      new_dataset_memre_export_path(dataset)
    end
  end

  def metadata_file_options
    if @dataset.instrument_rule
      @dataset.instrument_rule.metadata_file_type_names.join('/')
    end
  end

  def metadata_file_types
    if @dataset.instrument_rule
      @dataset.instrument_rule.metadata_file_types
    end
  end

  def get_instruments_json
    @instruments_json = {}
    Instrument.where(:is_available => true).each do |inst|
      key = @instruments_json[inst.instrument_class]
      if !key
        @instruments_json[inst.instrument_class] = {inst.name => inst.id}
      else
        @instruments_json[inst.instrument_class][inst.name] = inst.id
      end
    end
    @instruments_json.to_json.html_safe
  end


  def local_date(date)
    date.strftime("%d/%m/%Y %H:%M:%S")
  end


  def show_thumbnail(attachment)
    if attachment.preview_file.present?
      thumbs_html = image_tag preview_attachment_path(attachment),
                              :width => "100%",
                              :alt => escape_once(attachment.filename)
      thumbs_html += content_tag :span, image_tag(preview_attachment_path(attachment))
      link_to thumbs_html, download_attachment_path(attachment), :class => "thumbnail"
    else
      if attachment.instrument_file? and attachment.format == 'folder'
        thumbnail_img(attachment.instrument_file_type.name.downcase)
      elsif attachment.format == 'folder'
        thumbnail_img('folder')
      elsif known_file_type?(attachment)
        thumbnail_img(attachment.file_extension.downcase)
      else
        thumbnail_img('unknown')
      end
    end
  end

  def show_filename(attachment)
    if attachment.preview_file.present?
      inner_thumb_html = escape_once(attachment.filename)
      inner_thumb_html += content_tag(:span, image_tag(preview_attachment_path(attachment)))
      thumbs_html = content_tag :span, inner_thumb_html.html_safe, :class => "thumbnail"
      thumbs_html
    else
      attachment.filename
    end
  end

  def known_file_type?(attachment)
    return false if attachment.file_extension.nil?
    APP_CONFIG['known_formats'].include?(attachment.file_extension.downcase)
  end

  def thumbnail_img(file_type)
    "<img class=\"dataset_thumb\" src=\"/images/icon.#{file_type}.png\">".html_safe
  end

  def upload_prompt(instrument)
    if instrument.upload_prompt.present?
      instrument.upload_prompt
    else
      "Select files or folders to upload"
    end
  end

  def update_prompt(attachment)
    if attachment.format == "folder"
      "Choose a folder to upload"
    elsif attachment.file_extension.nil?
      "Choose a file to upload"
    else
      "Choose a #{attachment.file_extension} file to upload"
    end
  end

  def attachment_download_link(attachment)
    link_to "<span>Download</span>".html_safe, download_attachment_path(attachment), :class => "button"
  end

  def visualisation_tab_title
    att = @dataset.visual_attachment
    att.nil? ? '' : att.filename
  end

  def visualisation_partial
    if can_visualise?(@dataset.instrument)
      @visualisation_attachment = @dataset.visual_attachment
      if @visualisation_attachment.nil?
        return 'missing_visualisation'
      else
        name = @visualisation_attachment.instrument_file_type.visualisation_handler
        unless name.nil?
          return name.underscore
        end
      end
    end
    'no_visualisation'
  end

  def visualisation_file_options
    @dataset.instrument_rule.visualisation_file_type_names.join('/')
  end

  def metadata_value(metadata)
    result = sanitize newline_to_br(metadata.value)
    if /^http\:\/\//.match(result)
      result = "<a href=\"#{metadata.value}\">#{result}</a>".html_safe
    end
  end

  def visualisation_types
    @dataset.instrument_rule.visualisation_file_types
  end

  def can_visualise?(instrument)
    (instrument.instrument_rule and
        !instrument.instrument_rule.visualisation_file_type_names.empty?)
  end

  def non_empty_projects(projects)
    project_list = []
    projects.each do |project|
      if has_samples?(project)
        project_list << project
      end
    end
    project_list
  end

  def get_samples_json(projects)
    def get_samples(samples)
      samples_json = {}
      samples.map { |s| samples_json[s.id] = s.name }
      samples_json
    end

    project_json = {}
    projects.each do |project|
      next unless has_samples?(project)
      project_json[project.id] = {
          "experiments" => {},
          "samples" => get_samples(project.samples)
      }
      project.experiments.each do |exp|
        unless exp.samples.empty?
          project_json[project.id]['experiments'][exp.id] = {
              'name' => exp.name,
              'samples' => get_samples(exp.samples)
          }
        end
      end
    end
    project_json.to_json.html_safe
  end

end
