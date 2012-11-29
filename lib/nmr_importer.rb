class NMRImporter
  require 'acdata-dataset-api'
  require_relative 'attachment_builder'

  def self.import(base_dir, skip_duplicates=true)
    instrument_dirs = Dir.glob(File.join(base_dir, '*'))
    instrument_dirs.each do |instrument_dir|
      instrument = Instrument.find(File.basename(instrument_dir).to_i)
      next if instrument.nil?

      user_dirs = Dir.glob(File.join(instrument_dir, '*'))
      user_dirs.each do |user_dir|
        user = User.find(File.basename(user_dir).to_i)
        project = Project.where(:name => 'NMR Server Data', :user => user).first
        if project.nil?
          project = Project.create!(:name => 'NMR Server Data', :user => user)
        end
        sample_dirs = Dir.glob(File.join(user_dir, '*'))
        sample_dirs.each do |sample_dir|
          sample_name = File.basename(sample_dir)
          if skip_duplicates
            next if project.samples.where(:name => sample_name).present?
          end
          sample = project.samples.create!(:name => sample_name)
          dataset_dirs = Dir.glob(File.join(sample_dir, '*'))
          dataset_dirs.each do |dataset_dir|
            dataset = self.create_dataset(dataset_dir, instrument, sample, user)
            #attach_jcamp(dataset_dir, dataset)
          end

        end
      end
      FileUtils.rm_rf(instrument_dir)

    end
  end

  def self.create_dataset(dataset_dir, instrument, sample, user)
    title = self.extract_title(dataset_dir)
    dataset = sample.datasets.create!(:name => title, :instrument => instrument)
    files_struct, file_map = ACDataDatasetAPI.build_files_structure([File.open(dataset_dir)])
    builder = AttachmentBuilder.new(file_map, APP_CONFIG['files_root'], DatasetRules)
    builder.build(dataset, files_struct)

    #attach jcamp
    path_components = dataset_dir.to_s.split('/').to_a
    if !path_components.empty?
      dir_num = path_components.last!
      dir_dateuser = path_components.last!
      jcamp_path = "#{dataset_dir}/pdata/1/#{dir_dateuser}_#{dir_num}_1.dx"
      if File.exist?(jcamp_path)
        files_struct, file_map = ACDataDatasetAPI.build_files_structure([File.open(jcamp_path)])
        builder = AttachmentBuilder.new(file_map, APP_CONFIG['files_root'], DatasetRules)
        builder.build(dataset, files_struct)
      end
    end
    return dataset
  end

  def self.extract_title(nmr_dir)
    title_file_path = File.join(nmr_dir, 'pdata', '1', 'title')
    title = "Untitled"
    if File.exists?(title_file_path)
      file = File.open(title_file_path, 'rb')
      text = file.read
      text.gsub!(/(\r|\n)+/, ' ')
      text.strip!
      title = text unless text.empty?
    end

    title += " - #{nmr_dir[/\w+$/]}"
    title
  end


end