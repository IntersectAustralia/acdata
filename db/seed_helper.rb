require 'yaml'

config_file = File.expand_path(File.join('..', '..', 'config', 'acdata_config.yml'), __FILE__)
@config = YAML::load_file(config_file)
@env = ENV["RAILS_ENV"] || "development"

def create_roles_and_permissions
  Role.destroy_all

  Role.create!(:name => "Superuser")
  Role.create!(:name => "Moderator")
  Role.create!(:name => "Researcher")
end

def create_instrument_file_types
  InstrumentFileType.destroy_all

  config_file = File.expand_path('../../config/instrument_file_types.yml', __FILE__)
  config = YAML::load_file(config_file)
  file_set = ENV["RAILS_ENV"] || "development"
  config[file_set]['instrument_file_types'].each do |hash|
    InstrumentFileType.create!(hash)
  end
end

def import_fluorescent_labels
  FluorescentLabel.destroy_all

  config_file = File.expand_path('../../config/fluorescent_labels.yml', __FILE__)
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


def create_initial_users
  User.destroy_all
  config_file = File.expand_path('../../config/initial_users.yml', __FILE__)
  config = YAML::load_file(config_file)

  user_set = ENV["RAILS_ENV"] || "staging"
  return unless config.has_key?(user_set)

  config[user_set]['users'].each do |hash|
    next if hash['role'].nil?

    role = hash.delete('role')
    create_user(hash)
    set_role(hash['login'], role)
  end
end

def create_user(attrs)
  puts "Creating: #{attrs.inspect}"
  u = User.new(attrs)
  u.activate
  u.save!
end

def set_role(login, role)
  user = User.where(:login => login).first
  role = Role.where(:name => role).first
  user.role = role
  user.save!
end

def create_instruments
  Instrument.destroy_all

  config_file = File.expand_path('../../config/instruments.yml', __FILE__)
  config = YAML::load_file(config_file)
  instrument_set = ENV["RAILS_ENV"] || "development"
  config[instrument_set].each do |hash|
    next if hash['name'].nil? || hash['instrument_class'].nil?
    if hash.include?('instrument_file_types')
      file_types = hash['instrument_file_types'].map { |name| InstrumentFileType.find_by_name(name) }
      hash['instrument_file_types'] = file_types
    end
    if hash.include?('instrument_rules')
      rules = InstrumentRule.create(hash['instrument_rules'])
      hash['instrument_rule'] = rules
      hash.delete('instrument_rules')
    end
    i = Instrument.new(hash)
    i.save!
    p AndsHandle.assign_handle(i)
  end
end

def add_settings
  Settings.instance.update_attribute(:file_size_limit, APP_CONFIG['eln_file_size_limit'])
end

def set_slide_scanning_email
  Settings.instance.update_attribute(:slide_scanning_email, APP_CONFIG['slide_scanning_request_admin_email'])
end

def set_handle_ranges
  AndsHandle.destroy_all
  Settings.instance.update_attributes(:start_handle_range => "hdl:1959.4/004_300", :end_handle_range => "hdl:1959.4/004_2000")
end

def backup_old_projects
  files_root = @config[@env]['files_root']
  old_dir = File.join(files_root, 'old', Time.now.strftime('%Y%m%d_%H%M%S'))
  FileUtils.mkdir_p(old_dir)
  FileUtils.mv(Dir.glob(File.join(files_root, 'project_*')), old_dir)
end

