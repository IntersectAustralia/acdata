require "yaml"
require "fileutils"
#require "path_builder"

def populate_data

  User.all.map { |user| user.project_memberships.delete_all }
  User.delete_all
  Project.delete_all
  Experiment.delete_all
  Sample.delete_all
  Dataset.delete_all
  Attachment.delete_all
  ElnExport.delete_all
  ElnBlog.delete_all
  delete_files

  create_test_users
  load_data_from_backup_dir('/home/seanl/tmp/20121130_104800')
  share_projects
  load_external_data
end

def load_data_from_backup_dir(dir)
  Dir.foreach(dir) do |filename|
    next if filename == '.' or filename == '..'

    if File.directory?("#{dir}/#{filename}")
      puts "Loading data for #{filename}"
      user = User.find_by_login(filename)
      user_data = YAML.load_file("#{dir}/#{filename}/project_data.yml")

      # Projects
      user_data.each do |p|
        project = user.projects.create(
            :name => p['name'],
            :description => p['description'],
            :url => p['url']
        )
        puts "Created project: #{project.name} (#{project.id})"

        # Experiments of this project
        p['experiments'].each do |e|
          experiment = project.experiments.create(
              :name => e['name'],
              :description => e['description']
          )
          puts "Created experiment: #{project.name} (#{project.id}) #{experiment.name} (#{experiment.id})"

          # Samples of this experiment
          e['samples'].each do |s|
            e_sample = experiment.samples.create(
                :name => s['name'],
                :description => s['description']
            )
            puts "Created sample: #{project.name} (#{project.id}) #{experiment.name} (#{experiment.id}) #{e_sample.name} #{e_sample.id}"

            # Datasets of this sample
            s['datasets'].each do |d|
              dataset = e_sample.datasets.create(
                  :name => d['name'],
                  :instrument => Instrument.find_by_name(d['instrument_name'])
              )
              puts "Created dataset: #{project.name} (#{project.id}) #{e_sample.name} (#{e_sample.id}) #{dataset.name} #{dataset.id}"
            end
          end

        end

        # Samples of this project
        p['samples'].each do |s|
          p_sample = project.samples.create(
              :name => s['name'],
              :description => s['description']
          )
          puts "Created sample: #{project.name} (#{project.id}) #{p_sample.name} (#{p_sample.id})"

          # Datasets of this sample
          s['datasets'].each do |d|
            dataset = p_sample.datasets.create(
                :name => d['name'],
                :instrument => Instrument.find_by_name(d['instrument_name'])
            )
            puts "Created dataset: #{project.name} (#{project.id}) #{p_sample.name} (#{p_sample.id}) #{dataset.name} #{dataset.id}"
          end
        end

      end
    end
  end
end

def create_test_users
  config_file = File.expand_path('../../../config/test_users.yml', __FILE__)
  config = YAML::load_file(config_file)

  user_set = ENV["RAILS_ENV"] || "development"
  config[user_set]['users'].each do |hash|
    next if hash['role'].nil?

    role = hash.delete('role')
    create_user(hash)
    set_role(hash['login'], role)
  end

  create_unapproved_user(:login => "u1", :email => "unapproved1@example.com.au", :first_name => "Unapproved", :last_name => "One", :password => 'Pass.123', :is_student => false)
  create_unapproved_user(:login => "u2", :email => "unapproved2@example.com.au", :first_name => "Unapproved", :last_name => "Two", :password => 'Pass.123', :is_student => false)
end

def create_test_projects
  random = Random.new
  pdf_file = File.expand_path('../../../sample_files/rocket-emission-spectra.pdf', __FILE__)
  @approved_users.each do |user|
    1.times do |i|
      begin
        name = make_name(random.rand(2..5))
      end until Project.find_by_name(name).nil?
      project = user.projects.create(
          :name => name,
          :description => Faker::Lorem.sentence,
          :url => 'http://www.jcamp-dx.org/'
      )
      puts "Created project: #{project.name} (#{project.id})"
      project.document = File.new(pdf_file) if i == 0
      project.save!
    end
  end
end

def create_test_experiments
  @approved_users.each do |user|
    user.projects.each do |project|
      1.times do |i|
        experiment = project.experiments.create(:name => make_name(2), :description => "This is a dummy experiment.")
        puts "Created experiment: #{project.name} (#{project.id}) #{experiment.name} (#{experiment.id})"
      end
    end
  end
end

def create_test_samples
  @approved_users.each do |user|
    # Create samples under the first project
    project = user.projects.first
    1.times do |i|
      project.samples.create(:name => make_name(2), :description => "This is a dummy sample.")
    end

    # Create samples under the first experiment
    experiment = project.experiments.first
    1.times do |i|
      experiment.samples.create(:name => make_name(2), :description => "This is a dummy sample.")
    end
  end

end

def delete_files
  FileUtils::rm_r(Dir.glob(File.join(get_dataset_path, '/project_*')), {:secure => true})
end

def create_test_datasets
  raman_instrument = Instrument.find(
    :all, :conditions => [ 'name LIKE ?', '%Ramanstation%' ]).first
  nmr_instrument   = Instrument.find(
    :all, :conditions => [ 'name LIKE ?', '%Bruker DPX%' ]).first
  potentiostat_instrument = Instrument.find(
    :all, :conditions => [ 'name LIKE ?', '%Potentiostat%' ]).first
  ftir_instrument = Instrument.find(
    :all, :conditions => [ 'name LIKE ?', '%FTIR%' ]).first

  potentiostat = InstrumentFileType.find_by_name('Potentiostat (.txt)')
  dx           = InstrumentFileType.find_by_name('JCAMP-DX (v4)')
  sp           = InstrumentFileType.find_by_name('SP (RamanStation)')
  nmr          = InstrumentFileType.find_by_name('NMR')

  # Hint: use shell command "file -i <filename>" to get mime type
  dx_file = Rack::Test::UploadedFile.new(Rails.root.join("sample_files", 'ramanstation.dx'), 'text/plain; charset=iso-8859-1')
  sp_file = Rack::Test::UploadedFile.new(Rails.root.join("sample_files", 'ramanstation.sp'), 'application/octet-stream')
  jpg_file = Rack::Test::UploadedFile.new(Rails.root.join("sample_files", 'emission.jpg'), 'image/jpeg')
  potentiostat_file = Rack::Test::UploadedFile.new(Rails.root.join("sample_files", 'potentiostat.txt'), 'text/plain; charset=us-ascii')
  pdf_file =  Rack::Test::UploadedFile.new(Rails.root.join("sample_files", 'rocket-emission-spectra.pdf'), 'application/pdf')
  ftir_file = Rack::Test::UploadedFile.new(Rails.root.join("sample_files", 'FTIR.dx'), 'text/plain; charset=iso-8859-1')

  raman_files = {
    :dirStruct => ActiveSupport::JSON.encode([
      { "file_1" => 'ramanstation.dx' },
      { "file_2" => 'ramanstation.sp' },
      { "file_3" => 'emission.jpg' }
    ]),
    :file_1 => dx_file,
    :file_2 => sp_file,
    :file_3 => jpg_file
  }
  potentiostat_files = {
    :dirStruct => ActiveSupport::JSON.encode(
                  [ { "file_1" => 'potentiostat.txt' },
                    { "file_2" => 'rocket-emission-spectra.pdf' } ]),
    :file_1 => potentiostat_file,
    :file_2 => pdf_file
  }

  nmr_files = {
    :dirStruct => ActiveSupport::JSON.encode([
      {
        "folder_root"=>"nmr",
        "file_1"=>"nmr/fid",
        "file_2"=>"nmr/acqus",
        "file_3"=>"nmr/acqu",
        "folder_4"=>"nmr/pdata",
        "folder_5"=>"nmr/pdata/1",
        "file_6"=>"nmr/pdata/1/proc",
        "file_7"=>"nmr/pdata/1/procs",
        "file_8"=>"nmr/pdata/1/title"
      },
      { "file_9" => 'ramanstation.dx', }
    ]),
    :file_1 => Rack::Test::UploadedFile.new(Rails.root.join("sample_files/nmr", "fid")),
    :file_2 => Rack::Test::UploadedFile.new(Rails.root.join("sample_files/nmr", "acqus")),
    :file_3 => Rack::Test::UploadedFile.new(Rails.root.join("sample_files/nmr", "acqu")),
    :file_6 => Rack::Test::UploadedFile.new(Rails.root.join("sample_files/nmr/pdata/1", "proc")),
    :file_7 => Rack::Test::UploadedFile.new(Rails.root.join("sample_files/nmr/pdata/1", "procs")),
    :file_8 => Rack::Test::UploadedFile.new(Rails.root.join("sample_files/nmr/pdata/1", "title")),
    :file_9 => dx_file
  }

  ftir_files = {
    :dirStruct => ActiveSupport::JSON.encode( [ { "file_1" => 'FTIR.dx' } ]),
    :file_1 => ftir_file
  }

  @approved_users.each do |user|
    user.projects.each do |project|
      project.samples.each_with_index do |sample, i|
        case i
        when 0
          create_dataset(sample, raman_instrument, raman_files)
        when 1
          create_dataset(sample, nmr_instrument, nmr_files)
        when 2
          create_dataset(sample, ftir_instrument, ftir_files)
        else
          create_dataset(sample, potentiostat_instrument, potentiostat_files)
        end
      end

      project.experiments.each do |experiment|
        experiment.samples.each do |sample|
          create_dataset(sample, raman_instrument, raman_files)
        end
      end
    end
  end
end

def create_dataset(sample, instrument, params)
  dataset = sample.datasets.create(
      :name => make_name(2),
      :instrument => instrument
  )
  dataset_dir = File.join(get_dataset_path, PathBuilder::Path.file_path(dataset))
  FileUtils::mkdir_p(dataset_dir)

  params[:destDir] = "#{sample.id}/#{dataset.id}"
  builder = AttachmentBuilder.new(params, APP_CONFIG['files_root'], DatasetRules)
  json_string = params[:dirStruct]
  file_list = ActiveSupport::JSON.decode(json_string)
  result = builder.build(dataset, file_list)
  puts result.inspect

end

def get_dataset_path
  config = YAML.load_file("#{Rails.root.to_s}/config/acdata_config.yml")
  env = ENV["RAILS_ENV"] || "development"
  sensitive_data = YAML.load_file("#{config[env]['deploy_config_root']}/acdata_deploy_config.yml")
  config[env].merge!(sensitive_data[env])

  config[env]['files_root']
end

def share_projects
  users = User.all.select { |user| user.projects.size > 0 }
  (0..users.size-1).each do |i|
    project = users[i].projects[0]
    project.members << users[i-1]
    project.collaborators << users[i-2]
    project.save!
  end
end

def set_role(login, role)
  user = User.where(:login => login).first
  role = Role.where(:name => role).first
  user.role = role
  user.save!
end

def create_user(attrs)
  u = User.new(attrs)
  u.activate
  u.save!
end

def create_unapproved_user(attrs)
  u = User.new(attrs.merge(:password => "Pass.123"))
  u.update_attribute(:status, 'U')
  u.save!
end

def load_external_data
  require_relative 'data_manager.rb'

  puts "Adding FOR Codes"
  import_for_codes
  puts "Adding SEO Codes"
  import_seo_codes
  puts "Adding Fluorescent Labels"
  import_fluorescent_labels
  puts "Adding Slide Guidelines"
  import_slide_guidelines

  puts "Adding ANDS Party Records"
  ands_harvester = AndsPartyHarvester.new
  party_file = Rails.root.join('spec/resources/party_records.xml')
  doc = Nokogiri::XML(IO.read(party_file))
  ands_harvester.create_records(doc)

  puts "Adding RDA Grant Records"
  rda_harvester = RdaGrantHarvester.new
  grants_file = Rails.root.join('spec/resources/rda_grants.xml')
  doc = Nokogiri::XML(IO.read(grants_file))
  rda_harvester.create_grant_records(doc)

  puts "Adding MemRE Properties"
  config = YAML.load_file("#{Rails.root.to_s}/config/acdata_config.yml")
  env = ENV["RAILS_ENV"] || "development"

  url = config[env]['memre']['base_url']

  MemreHarvester.fetch_and_store_properties(url)
end

def make_name(words)
  Faker::Lorem.words(words).map { |word| word.capitalize }.join(' ')
end
