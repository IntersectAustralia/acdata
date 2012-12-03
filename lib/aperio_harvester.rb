require 'mechanize'
require 'csv'

class AperioHarvester

  def self.harvest(config)
    harvester = AperioHarvester.new(config)

    harvester.log_in_to_web_app

    projects_to_harvest = harvester.list_projects

    projects_to_harvest.each do |project_id|
      harvester.process_project project_id
    end
  ensure
    harvester.close_aperio_connection unless harvester == nil
  end

  def process_project(project_id)
    ActiveRecord::Base.transaction do
      Rails.logger.debug("Harvesting Aperio project #{project_id}")
      project_data = get_project_data project_id
      CSV.parse(project_data, :headers => true) do |slide_data|
        process_slide slide_data
      end
      mark_project_as_harvested project_id
      Rails.logger.info("Successfully harvested Aperio project #{project_id}")
    end
  rescue Net::HTTP::Persistent::Error => exc
    Rails.logger.error("Error connecting to Aperio: #{exc}")
  rescue Exception => exc
    Rails.logger.error("other error #{exc}")
  end

  def initialize(config)
    @config = config
    @agent = Mechanize.new
    @agent.basic_auth(@config[:username],@config[:password])
    @agent.read_timeout = 300
    @instrument = Instrument.find_by_name(@config[:instrument_name])
    @slide_instrument_file_type = InstrumentFileType.find_by_name(@config[:slide_file_type])
    @label_instrument_file_type = InstrumentFileType.find_by_name(@config[:label_file_type])
    @samples = {}
    @aperio_client = AperioClient.new
  end

  def mark_project_as_harvested(project_id)
    @aperio_client.update_project(project_id, :ColumnACDataUpdate => 'No')
  end

  def close_aperio_connection
    @aperio_client.close if @aperio_client
  end

  def log_in_to_web_app
    page = @agent.get(@config[:base_url])
    login_form = page.form('frmLogon')
    login_form.user = @config[:username]
    login_form.password = @config[:password]
    page = @agent.submit(login_form, login_form.buttons.first)

    # Acknowledge terms
    ack_form = page.form
    page = @agent.submit(ack_form, ack_form.buttons.first)
    page = @agent.page.link_with(:text => "Project").click
    page = @agent.page.link_with(:text => "Projects").click

    Rails.logger.info("Logged in to Aperio successfully")
  end

  def list_projects
    page = @agent.post(@config[:project_list_url], {
      "BasedOnSearchId" => "-1",
      "TableName" => "Project",
      "FieldName[]" => "ColumnACDataUpdate",
      "Table[]" => "Project",
      "FieldOperator[]" => "=",
      "FieldValue[]" => "Yes",
      "FieldValue2[]" => "",
      "SearchName" => ""
    })

    page.links.select { |l| l.text.match(/^\d+$/) }.map { |l| l.text }
  end

  def get_project_data(project_id)
    export_form_full_url = @config[:export_data_url] + "&Ids[]=#{project_id}"
    page = @agent.get(export_form_full_url)
    form = page.form('ExportOptions')

    form.checkboxes.each { |cb| cb.check }

    page = @agent.submit(form, form.buttons.first)
    Rails.logger.info("Got project data for project #{project_id}")
    page.content
  end

  def process_slide(slide_data)
    # Specimens in Aperio are samples in AC DATA
    sample_id = slide_data["User Specimen ID"].to_i
    project_id = slide_data["ACData ID"].to_i

    project = Project.find(project_id) if project_id > 0

    if (project && sample_id > 0)
      sample = create_or_update_sample(project, sample_id, slide_data)
      create_or_update_dataset(sample, slide_data)
    end
  rescue Exception => e
    Rails.logger.error("Error creating dataset")
    Rails.logger.error(e.backtrace.join("\n"))
  end

  def create_or_update_sample(project, sample_id, slide_data)
    return @samples[sample_id] if @samples[sample_id]

    sample = Sample.where(:external_data_source => 'Aperio').where(:external_id => sample_id).first

    # Create sample if it does not exist in the database
    unless sample
      sample = project.samples.new(:name => sample_id.to_s, 
                                   :external_data_source => 'Aperio', 
                                   :external_id => sample_id)
    end

    # Update description in all cases
    sample.description = sample_description(slide_data)
    sample.save!

    # We initialise the hash and return the value of sample
    @samples[sample_id] = sample
  end

  def sample_description(slide_data)
    """
      Specimen ID: #{slide_data["Specimen ID"]}
      Accession Number: #{slide_data["Accession Number"]}
      Procedure: #{slide_data["Procedure"]}
      Body Site ID: #{slide_data["Body Site"]}
      Collected Date: #{slide_data["Collected Date"]}
      Received Date: #{slide_data["Received Date"]}
      Released Date: #{slide_data["Released Date"]}
      Specimen Received: #{slide_data["Specimen Received"]}
      Gross Description: #{slide_data["Gross Description"]}
      Microscopic Description: #{slide_data["Microscopic Description"]}
      Storage Location: #{slide_data["Storage Location"]}
      Status: #{slide_data["Status"]}
      Hospital Accession Number: #{slide_data["Hospital Accession Number"]}
      """
  end

  def create_or_update_dataset(sample, slide_data)
    slide_id = slide_data["Slide ID"].to_i
    return unless slide_id > 0

    dataset = Dataset.where(:external_data_source => 'Aperio').where(:external_id => slide_id).first

    # Create dataset if it does not exist in the database
    unless dataset
      # There is no "File Name", we extract it from path
      path = slide_data["File Location"]
      slide_data["File Name"] = /.*\\(.*)/.match(path)[1]

      dataset = sample.datasets.new(:name => slide_data["File Name"],
                                    :external_data_source => 'Aperio',
                                    :external_id => slide_id,
                                    :instrument => @instrument)
      dataset.save!
    end

    dataset.metadata_values.clear

    add_thumbnail('slide', dataset, slide_data["Image ID"].to_i)
    add_thumbnail('label', dataset, slide_data["Image ID"].to_i)

    dataset.metadata_values.create!(:key => 'ID', :value => slide_data["Slide ID"], :core => true, :supplied => false)
    dataset.metadata_values.create!(:key => 'Block ID', :value => slide_data["Block ID"], :core => true, :supplied => false)
    dataset.metadata_values.create!(:key => 'Stain ID', :value => slide_data["Stain"], :core => true, :supplied => false)
    dataset.metadata_values.create!(:key => 'Description', :value => slide_data["Description"], :core => true, :supplied => false)

    dataset.metadata_values.create!(:key => 'Data Group ID', :value => slide_data["Data Group"], :core => false, :supplied => false)
    dataset.metadata_values.create!(:key => 'Last Job Status', :value => slide_data["Analysis Progress"], :core => false, :supplied => false)

    dataset.metadata_values.create!(:key => 'Image ID', :value => slide_data["Image ID"], :core => true, :supplied => false)

    dataset.metadata_values.create!(:key => 'Scan Date', :value => slide_data["Captured Date"], :core => false, :supplied => false)
    dataset.metadata_values.create!(:key => 'Compressed File Location', :value => slide_data["File Location"], :core => true, :supplied => false)
    dataset.metadata_values.create!(:key => 'Rack', :value => slide_data["Rack"], :core => false, :supplied => false)
    dataset.metadata_values.create!(:key => 'Slot', :value => slide_data["Slot"], :core => false, :supplied => false)


    dataset.metadata_values.create!(:key => 'Scan Status', :value => slide_data["Scan Status"], :core => true, :supplied => false)
    dataset.metadata_values.create!(:key => 'Quality Factor', :value => slide_data["Quality Factor"], :core => true, :supplied => false)
    dataset.metadata_values.create!(:key => 'Scan Scope ID', :value => slide_data["ScanScope ID"], :core => true, :supplied => false)


    dataset.metadata_values.create!(:key => 'Run Time', :value => slide_data["Run Time"], :core => false, :supplied => false)
    dataset.metadata_values.create!(:key => 'TWidth', :value => slide_data["TWidth"], :core => false, :supplied => false)
    dataset.metadata_values.create!(:key => 'THeight', :value => slide_data["THeight"], :core => false, :supplied => false)
  end

  def thumbnail_url(type, image_id)
    config_thumbnail_url = "#{type}_thumbnail_url"
    @config[config_thumbnail_url.to_sym].gsub('__image_id__', image_id.to_s)
  end

  def add_thumbnail(type, dataset, image_id)
    return unless image_id > 0

    has_already_been_downloaded = dataset.attachments.any? { |at| at.instrument_file_type == get_instrument_file_type_for(type)}
    return if has_already_been_downloaded

    image_url = thumbnail_url(type, image_id)

    begin
      image = @agent.get(image_url)
      image_filename = "#{image.filename}_"+type+".jpg"
      dest_dir = File.join(@config[:files_root], PathBuilder::Path.file_path(dataset))
      file_path = File.join(dest_dir, image_filename)
      image.save(file_path)
    rescue Exception => e
      Rails.logger.error e
      Rails.logger.error("Cannot retrieve Aperio #{type} image")
      Rails.logger.error(e.backtrace.join("\n"))
      return
    end

    begin
      preview_file, preview_mime_type = 
        PreviewBuilder.make_image_preview(file_path)

      attachment = dataset.attachments.create!(:filename => image_filename,
                                               :format => 'file',
                                               :preview_file => preview_file,
                                               :preview_mime_type => preview_mime_type,
                                               :instrument_file_type => get_instrument_file_type_for(type))

      dataset.metadata_values.create!(:key => "#{type.to_s.capitalize} Thumbnail",
                                      :value => image_url,
                                      :core => true,
                                      :attachment => attachment,
                                      :supplied => false)
    rescue Exception => e
      pp e
      Rails.logger.error e
      Rails.logger.error("Cannot save Aperio image")
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end

  def get_instrument_file_type_for(type)
    type == :label ? @label_instrument_file_type : @slide_instrument_file_type
  end

end
