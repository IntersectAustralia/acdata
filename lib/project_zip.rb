require 'find'
module ProjectZip
  # Say:
  # src_path is /data/acdata-samples/project_1/
  # zip_root_folder_name is "blah"
  #
  # So the zip file is created with a folder "blah" which contains the files
  # found under "/data/acdata-samples/project_1/"

  def generate_zip(src_path, zip_folder_path)
    tempfile = File::Temp.temp_name
    Zip::ZipOutputStream.open(tempfile) do |zos|
      add_entries(src_path, zip_folder_path, zos)
    end
    return tempfile
  end

  def add_entries(src_path, zip_folder_path, zos)
    # executes block on all files and
    # directories in path recursively
    Find.find(src_path) do |f|
      next if FileTest.directory?(f)
      next if File.fnmatch('**/.*', f)
      Rails.logger.debug("Up to file #{f}")

      # /data/acdata-samples/project_1/file1.txt --> blah/file1.txt
      filepath = f.sub(src_path, zip_folder_path)
      Rails.logger.debug("Adding #{f} to #{filepath}")
      zos.put_next_entry(filepath)
      # http://stackoverflow.com/questions/4956282/losing-data-when-zipping-files
      # read as binary
      zos << File.open(f,'rb'){|file|file.read}
    end
  end

  def generate_project_zip(container)
    tempfile = File::Temp.temp_name
    Zip::ZipOutputStream.open(tempfile) do |zos|

      if container.respond_to?(:document) and container.document?
        documents_path = File.join(container.name.to_filename, 'documents')
        add_entries(File.dirname(container.document.path), documents_path, zos)
      end

      if container.is_a?(Project)
        container.experiments.each do |experiment|
          if experiment.document?
            documents_path = File.join(container.name.to_filename, experiment.name.to_filename, 'documents')
            add_entries(File.dirname(experiment.document.path), documents_path, zos)
          end
          add_samples(experiment.samples, container, experiment, zos)
        end
      end

      if container.is_a?(Sample)
        add_samples([container], nil, nil, zos)
      else
        add_samples(container.samples, container, nil, zos)
      end

    end

    return tempfile
  end

  def add_samples(samples, level1, level2, zos)
    samples.each do |sample|
      sample.datasets.each do |dataset|
        if dataset.attachments.present?
          src_path = dataset.dataset_path
          zip_folder_path =
            if level1.nil?
              "#{sample.name.to_filename}/#{dataset.name.to_filename}"
            elsif level2.nil?
              "#{level1.name.to_filename}/#{sample.name.to_filename}/#{dataset.name.to_filename}"
            else
              "#{level1.name.to_filename}/#{level2.name.to_filename}/#{sample.name.to_filename}/#{dataset.name.to_filename}"
            end
          add_entries(src_path, zip_folder_path, zos)
        end
      end
    end
  end

end
