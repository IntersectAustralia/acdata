class CapillaryPorometerTXTHandler < CapillaryPorometerFileHandler

  def recognise?(file_path)
    if (file_path.match(/\.txt$/i))
      return !self.class.get_test_type_from_file(file_path).nil?
    end
  end

  def self.get_test_type_from_file(file_path)
    return self.get_test_type(File.open(file_path))
  end

  def self.get_content(src_file)
    File.open(src_file)
  end

end
