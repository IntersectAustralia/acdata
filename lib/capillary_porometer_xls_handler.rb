class CapillaryPorometerXLSHandler < CapillaryPorometerFileHandler

  METADATA_WORKSHEET = 'Sheet1'

  def recognise?(file_path)
    if (file_path.match(/\.xlsx?$/i))
      return !self.class.get_test_type_from_file(file_path).nil?
    end
  end

  def self.get_test_type_from_file(file_path)
    begin
      book = Spreadsheet.open file_path
      sheet1 = book.worksheet METADATA_WORKSHEET
      return false unless sheet1

      sheet1.each_with_index do |row, index|
        line = row.join(' ')
        if line.match(/\S/)
          return self.get_test_type(StringIO.new(line))
        end
      end
    rescue Exception => e
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end

  def self.get_content(file_path)
    unless File.exists?(file_path)
      raise "#{file_path} does not exist"
    end
    book = Spreadsheet.open file_path
    sheet1 = book.worksheet METADATA_WORKSHEET
    content = ''
    if sheet1.nil?
      Rails.logger.error("CapillaryPorometerXLSHandler.get_content: #{file_path} does not have a #{METADATA_WORKSHEET} as expected")
    else
      sheet1.each do |row|
        content << row.join(' ') << "\n"
      end
    end
    StringIO.new(content)
  end

end
