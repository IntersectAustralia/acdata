class KeyValuePairFileParser


  def initialize(core_tags, extended_tags, supplied_tags, tag_mappings)
    @core_tags = core_tags
    @extended_tags = extended_tags
    @supplied_tags = supplied_tags
    @tag_mappings = tag_mappings
    @core_tags_mapped = @core_tags.map { |tag| map_key(tag) }

    @regex = /\A\s*(#{(@core_tags + @extended_tags).map { |t| Regexp.quote(t) }.join("|")})\s*[:|=](.*)\Z/
  end

  def parse(path, encoding="ISO-8859-1")
    metadata = {}
    file = File.open(path, "r:#{encoding}")
    extract_metadata(file)
  end

  def extract_metadata(content_stream, options={})
    metadata = {}
    content_stream.each do |line|
      if line =~ @regex
        matches = line.scan(@regex)
        key = matches[0][0]
        value = matches[0][1]
        value = value.strip if value
        if value and options[:compress_whitespace]
          value = value.gsub(/\s+/, ' ')
        end
        mapped_key = map_key(key)
        metadata[mapped_key] = {
            'value' => value,
            'core' => is_core?(mapped_key),
            'supplied' => false
        }
      end
    end
    content_stream.rewind
    extra_metadata = do_file_specific_parsing(content_stream)
    metadata.merge!(extra_metadata) unless extra_metadata.nil?
    supplied_metadata = generate_supplied_metadata
    metadata.merge!(supplied_metadata) unless supplied_metadata.blank?

    metadata
  end

  def do_file_specific_parsing(iostream)
    #do nothing, subclasses can override
  end

  private

  def generate_supplied_metadata
    metadata = {}
    @supplied_tags.each do |key|
      metadata[key] = {
          'value' => "",
          'core' => true,
          'supplied' => true
      }

    end

    metadata
  end

  def is_core?(key)
    @core_tags.include?(key) || @core_tags_mapped.include?(key)
  end

  def map_key(key)
    @tag_mappings.has_key?(key) ? @tag_mappings[key] : key
  end

end
