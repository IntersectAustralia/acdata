class InstrumentFileType < ActiveRecord::Base
  has_and_belongs_to_many :instruments
  validates_length_of :name, :maximum => 255

  def file_filter_match(filename)
    return true if filter.nil?

    file_filter_list.each do |extension|
      return true if filename.downcase.match(/\.#{extension}$/)
    end
    return false
  end

  def file_filter_list
    return [] if filter.nil?
    filter.split(/\s*;\s*/)
  end

  def parser
    return nil if parser_name.nil?
    @parser ||= Object::const_get(parser_name).new
  end

  def recognise?(file_path)
    file_filter_match(file_path) and
      has_no_parser_or_recognised_by_parser(file_path)
  end

  # obtains instrument from dataset and searches within
  # the instrument file types belonging to that instrument
  def self.identify(file_path, instrument)
    instrument.instrument_file_types.each do |file_type|
      return file_type if (file_type.recognise?(file_path))
    end
    nil
  end

  private
  def has_no_parser_or_recognised_by_parser(file_path)
    (parser.nil? || parser.recognise?(file_path))
  end


end
