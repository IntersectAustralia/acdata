require "yaml"
require "fileutils"
require 'attachment_builder'

@config = YAML.load_file("#{Rails.root.to_s}/config/acdata_config.yml")
@env = ENV["RAILS_ENV"] || "development"
sensitive_data = YAML.load_file("#{@config[@env]['deploy_config_root']}/acdata_deploy_config.yml")
@config[@env].merge!(sensitive_data[@env])

def files_root
  @config[@env]['files_root']
end

def backup_dir
  @backup_dir ||= File.join(@config[@env]['files_root'], 'backup', Time.now.strftime('%Y%m%d_%H%M%S'))
end

def newest_backup_dir
  @backup_base_dir ||= File.join(@config[@env]['files_root'], 'backup')
  backup_dir = Dir.entries(@backup_base_dir).grep(/^\d{8,}_\d{6}$/).sort.pop
  File.join(@backup_base_dir, backup_dir)
end

def delete_data
  puts "Are you sure you want to delete all project data from disk? [N/y]"
  input = STDIN.gets.chomp
  if input.match(/^y/)
    FileUtils::rm_r(Dir.glob(File.join(files_root, '/project_*')), {:secure => true})
  end
end

def save_data
  User.all.each do |user|
    next if user.projects.empty?

    dest_dir = File.join(backup_dir, user.login)
    if File.exists?(dest_dir)
      puts "ERROR: There is already a backup for #{user.login}, aborting"
    end
    puts "Creating #{dest_dir}"
    FileUtils.mkdir_p(dest_dir, :mode => 0750)
    projects = []
    user.projects.order(:created_at).each do |project|
      src_dir = File.join(files_root, "project_#{project.id}")
      p_hash = project.serializable_hash
      p_hash['experiments'] = get_experiments(project)
      p_hash['samples'] = get_samples(project)
      p_hash['viewers'] = project.viewers.map { |v| v.login }
      p_hash['collaborators'] = project.collaborators.map { |c| c.login }
      #puts p_hash.inspect
      projects << p_hash
      next unless File.exists?(src_dir)
      cp_r(src_dir, dest_dir)
    end
    File.open(File.join(dest_dir, 'project_data.yml'), 'w') { |f|
      f.write(YAML::dump(projects))
    }
  end

  save_instruments
end

def save_instruments
  instruments = []
  Instrument.all.each do |instrument|
    hash = {
        'name' => instrument.name,
        'instrument_class' => instrument.instrument_class,
        'description' => instrument.description,
        'is_available' => instrument.is_available,
        'upload_prompt' => instrument.upload_prompt,
        'email' => instrument.email,
        'voice' => instrument.voice,
        'managed_by' => instrument.managed_by,
        'instrument_file_types' => instrument.instrument_file_types.map(&:name)
    }
    if instrument.instrument_rule
      ir = instrument.instrument_rule
      hash['instrument_rules'] = {
          'visualisation_list' => ir.visualisation_list,
          'metadata_list' => ir.metadata_list,
          'unique_list' => ir.unique_list,
          'indelible_list' => ir.indelible_list,
          'exclusive_list' => ir.exclusive_list
      }
    end
    instruments << hash
  end
  File.open(File.join(backup_dir, 'instruments.yml'), 'w') { |f|
    f.write(YAML::dump(instruments))
  }
end

def assign_instruments
  Instrument.find_each do |instrument|

    if instrument.ands_handle
      puts "#{instrument.handle} already assigned to #{instrument.name}"
    else
      AndsHandle.assign_handle(instrument)
      puts "Assigned #{instrument.handle} to #{instrument.name}"

    end
  end
end

def get_experiments(project)
  exp = []
  project.experiments.order(:created_at).each do |e|
    hash = e.serializable_hash
    hash['samples'] = get_samples(e)
    exp << hash
  end
  exp
end

def get_samples(container)
  samples = []
  container.samples.order(:created_at).each do |s|
    hash = s.serializable_hash
    hash['datasets'] = get_datasets(s)
    samples << hash
  end
  samples
end

def get_datasets(sample)
  datasets = []
  sample.datasets.order(:created_at).each do |d|
    hash = d.serializable_hash
    instrument = Instrument.find(d.instrument_id)
    hash.delete('instrument_id')
    hash['instrument_name'] = instrument.name
    hash['instrument_class'] = instrument.instrument_class
#    hash['instrument_identifier'] = instrument.identifier
    hash['attachments'] = get_attachments(d)
    datasets << hash
  end
  datasets
end

def get_attachments(dataset)
  attachments = []
  dataset.attachments.order(:created_at).each do |a|
    hash = a.serializable_hash
    if !a.instrument_file_type.nil?
      instrument_type = InstrumentFileType.find(a.instrument_file_type.id)
      hash['instrument_file_type_name'] = instrument_type.name
    end
    hash.delete('instrument_file_type_id')
    attachments << hash
  end
  attachments
end

def restore_data
  restore_instruments
  User.all.each do |user|
    user_backup_dir = File.join(newest_backup_dir, user.login)
    puts "Restoring projects for #{user.login} from #{user_backup_dir}"
    next unless File.exists?(user_backup_dir)

    projects = YAML::load_file(File.join(user_backup_dir, 'project_data.yml'))
    if project_name_clashes?(projects, user)
      puts "Skipping restoration for #{user.login} due to name clashes."
      puts "Rename the clashing projects and try again."
      next
    end

    projects.each do |project|
      puts "Restoring: #{project['name']}"
      create_project(project, user, user_backup_dir)
    end
  end
end

def restore_instruments
  instruments_file = File.join(newest_backup_dir, 'instruments.yml')
  return unless File.exists?(instruments_file)

  instruments = YAML::load_file(instruments_file)
  instruments.each do |instrument|
    next if Instrument.find_by_name(instrument['name'])
    puts "Creating instrument: #{instrument['name']}"
    rules = instrument.delete('instrument_rules')
    if instrument.has_key?('instrument_file_types')
      file_types = instrument['instrument_file_types'].map { |name| InstrumentFileType.find_by_name(name) }
      instrument['instrument_file_types'] = file_types
    end
    i = Instrument.new(instrument)
    i.save!
    if rules
      rules['instrument_id'] = i.id
      instrument_rule = InstrumentRule.new(rules)
      instrument_rule.save!
    end
  end
end

def project_name_clashes?(projects, user)
  clashes = projects.map { |p| p['name'] } & user.projects.map { |p| p.name }
  clashes.each do |name|
    puts "ERROR: A project with name \"#{name}\" already exists"
  end
  !clashes.empty?
end

def create_project(project, user, user_backup_dir)
  experiments = project.delete('experiments')
  samples = project.delete('samples')
  viewers = project.delete('viewers')
  collaborators = project.delete('collaborators')
  old_id = project.delete('id')
  project['user_id'] = user.id

  new_project = Project.new(project)
  new_project.save!

  add_members(new_project, collaborators, 'collaborator')
  add_members(new_project, viewers, 'viewer')

  project_id = new_project.id
  puts "New project id: #{project_id}"

  project_backup = File.join(user_backup_dir, "project_#{old_id}")
  dest_dir = nil

  if File.exists?(project_backup)
    dest_dir = File.join(files_root, "project_#{project_id}")
    puts "Recreating #{project_backup} into #{dest_dir}"
    if File.exists?(dest_dir)
      puts "#{dest_dir} already exists, aborting"
      exit
    end
    mkdir(dest_dir, :mode => 0750)
    doc_dir = File.join(project_backup, 'documents')
    if File.exists?(doc_dir)
      cp_r(doc_dir, File.join(dest_dir, 'documents'))
    end
  end

  create_experiments(experiments, project_id, project_backup, dest_dir)
  create_samples(samples, 'Project', project_id, project_backup, dest_dir)
end

def add_members(project, members, type)
  members.each do |m|
    puts "\tLooking for #{type}: #{m}"
    member = User.find_by_login(m)
    next unless member
    puts "\tAdding #{m}"
    if type == 'collaborator'
      project.collaborators << member
    else
      project.viewers << member
    end
  end
  project.save!
end

def create_experiments(experiments, project_id, parent_src_dir, parent_dest_dir)
  experiments.each do |e|
    samples = e.delete('samples')
    old_id = e.delete('id')
    e['project_id'] = project_id
    new_exp = Experiment.new(e)
    new_exp.save!
    #puts new_exp.inspect
    new_id = new_exp.id

    src_dir = nil
    dest_dir = nil
    if !parent_src_dir.nil? and File.exists?(parent_src_dir)
      src_dir = File.join(parent_src_dir, "experiment_#{old_id}")
      dest_dir = File.join(parent_dest_dir, "experiment_#{new_id}")
      mkdir(dest_dir, :mode => 0750)
      doc_dir = File.join(src_dir, 'documents')
      if File.exists?(doc_dir)
        cp_r(doc_dir, File.join(dest_dir, 'documents'))
      end
    end

    create_samples(samples, 'Experiment', new_id, src_dir, dest_dir)
  end
end

def create_samples(samples, type, container_id, parent_src_dir, parent_dest_dir)
  samples.each do |sample|
    datasets = sample.delete('datasets')
    old_id = sample.delete('id')
    sample['samplable_type'] = type
    sample['samplable_id'] = container_id
    new_sample = Sample.new(sample)
    new_sample.save!
    new_id = new_sample.id
    #puts new_sample.inspect

    src_dir = nil
    dest_dir = nil
    if !parent_src_dir.nil? and File.exists?(parent_src_dir)
      src_dir = File.join(parent_src_dir, "sample_#{old_id}")
      dest_dir = File.join(parent_dest_dir, "sample_#{new_id}")
      mkdir(dest_dir, :mode => 0750)
    end

    create_datasets(datasets, new_id, src_dir, dest_dir)
  end
end

def create_datasets(datasets, sample_id, parent_src_dir, parent_dest_dir)
  datasets.each do |dataset|
    atts = dataset.delete('attachments')
    old_id = dataset.delete('id')

    dataset['sample_id'] = sample_id
    dataset['instrument_id'] = Instrument.where(
        :name => dataset['instrument_name'],
        :instrument_class => dataset['instrument_class']
    ).first.id
    dataset.delete('instrument_name')
    dataset.delete('instrument_class')
    new_dataset = Dataset.new(dataset)
    new_dataset.save!
    new_id = new_dataset.id

    if !parent_src_dir.nil? and File.exists?(parent_src_dir)
      src_dir = File.join(parent_src_dir, "dataset_#{old_id}")
      dest_dir = File.join(parent_dest_dir, "dataset_#{new_id}")
      mkdir(dest_dir, :mode => 0750)

      create_attachments(atts, new_dataset, src_dir, dest_dir)
    end

  end
end

def create_attachments(atts, dataset, parent_src_dir, parent_dest_dir)
  atts.each do |attachment|
    attachment.delete('id')
    attachment.delete('dataset_id')
    filename = attachment['filename']
    if attachment.include?('preview_file')
      attachment.delete('preview_file')
      attachment.delete('preview_mime_type')
    end
    if attachment.include?('instrument_file_type_name')
      file_type = InstrumentFileType.find_by_name(attachment['instrument_file_type_name'])
      attachment.delete('instrument_file_type_name')
      attachment['instrument_file_type'] = file_type
    end
    src_path = File.join(parent_src_dir, filename)
    dest_path = File.join(parent_dest_dir, filename)
    attachment['path'] = dest_path
    if File.directory?(src_path)
      cp_r(src_path, dest_path)
    else
      cp(src_path, dest_path)
    end
    attachment.keys.map { |k| attachment[k.to_sym] = attachment.delete(k) }
  end

  builder = AttachmentBuilder.new({}, files_root, DatasetRules)
  result = builder.create_attachments(atts, dataset, parent_dest_dir, {})
  puts result.inspect
end

def import_for_codes
  require 'csv'

  ForCode.destroy_all
  csv_path = File.expand_path('../../../config/FOR_CodeList.csv', __FILE__)
  CSV.foreach(csv_path, {:headers => true}) do |row|

    ForCode.create!(:code => row[0], :name => row[1])

  end
end

def import_seo_codes
  require 'csv'
  SeoCode.destroy_all
  csv_path = File.expand_path('../../../config/SEO_CodeList.csv', __FILE__)

  CSV.foreach(csv_path, {:headers => true}) do |row|

    SeoCode.create!(:code => row[0], :name => row[1])

  end

end

def import_fluorescent_labels
  FluorescentLabel.destroy_all

  config_file = File.expand_path('../../../config/fluorescent_labels.yml', __FILE__)
  config = YAML::load_file(config_file)
  file_set = ENV["RAILS_ENV"] || "development"
  config[file_set]['fluorescent_labels'].each do |name|
    FluorescentLabel.create!(:name => name)
  end
end

def import_slide_guidelines
  SlideGuideline.destroy_all

  config_file = File.expand_path("#{Rails.root}/config/slide_guidelines.yml", __FILE__)
  config = YAML::load_file(config_file)
  file_set = ENV["RAILS_ENV"] || "development"
  config[file_set]['slide_guidelines'].each do |description|
    SlideGuideline.create!(:description => description, :settings => Settings.instance)
  end
end
