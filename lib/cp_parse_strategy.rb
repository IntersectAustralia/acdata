class CPParseStrategy < KeyValuePairFileParser

  def do_file_specific_parsing(content_stream)
    date_regex = Regexp.new(/^\s*(\d{2})[\/-](\d{2})[\/-](\d{4})\s*$/)
    time_regex = Regexp.new(/TIME:\s+(\d+\:\d+\:\d+)/)
    metadata = {}
    time = nil
    content_stream.each do |line|
      line.match(date_regex) do |match|
        month, day, year = match.captures
        metadata['Date & Time'] = {
          'value' => "#{year}-#{month}-#{day}",
          'core' => true,
          'supplied' => false
        }
      end
      line.match(time_regex) do |match|
        time = match.captures.first
      end
    end
    if metadata.include?('Date & Time') and not time.nil? 
      metadata['Date & Time']['value'] += " #{time}"
    end
    metadata
  end

  def get_metadata(inputstream)
    extract_metadata(inputstream, :compress_whitespace => true)
  end

end
