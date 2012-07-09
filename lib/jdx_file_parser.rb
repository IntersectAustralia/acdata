class JDXFileParser

  BUFFER = 4000
  KEY_VALUE_REGEX = /##(.+?)=([^#]+(?=#))/m
  LEFTOVERS_REGEX = /##(.+?)=([^#]+)/m

  def initialize(core_tags, extended_tags, supplied_tags)
    @core_tags = core_tags
    @extended_tags = extended_tags
    @supplied_tags = supplied_tags
  end

  def self.version(file_path)
    File.open(file_path) do |file|
      header = file.read(BUFFER)
      if match = header.match(/##JCAMP[-_]?DX=\s*(\d+\.\d+)/)
        match.captures.first
      end
    end
  end

  def parse(src_file, encoding="ISO-8859-1")
    @encoding = encoding

    src_file = File.open(src_file, "r:#{@encoding}")
    core_set = @core_tags.keys
    ext_set  = @extended_tags.keys

    extract_metadata(core_set, ext_set, src_file)
  end

  def extract_metadata(core_set, ext_set, content_stream)
    leftover = ''
    metadata = {}
    core = Array.new(core_set)
    ext  = Array.new(ext_set)
    begin
      content = get_content(content_stream, leftover)
      unless content.nil?
        new_metadata, leftover = process_content("#{leftover}#{content}", core, ext)
        metadata.merge!(new_metadata)
      end
    end until content.nil? || (core.empty? and ext.empty?)

    if (leftover)
      new_metadata, leftover = process_content(leftover, core, ext, true)
      metadata.merge!(new_metadata)
    end

    supplied_metadata = generate_supplied_metadata
    metadata.merge!(supplied_metadata) unless supplied_metadata.blank?

    if metadata.include?('Date & Time') and metadata.include?('Time')
      metadata['Date & Time']['value'] += " #{metadata['Time']['value']}"
      metadata.delete('Time')
    end

    metadata
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

  def get_content(content_stream, leftover)
    return nil if content_stream.eof?
    content_stream.read(BUFFER)
  end

  def leftovers(content)
    content.match(/(##[^=]+=[^#]+)\z/m) {|m| m[0]}
  end

  def process_content(content, core_set, ext_set, last=false)
    metadata = {}
    content.scan(last ? LEFTOVERS_REGEX : KEY_VALUE_REGEX) {|tag,value|
      core = false
      if core_set.include?(tag)
        core_set.delete(tag)
        metadata_key = @core_tags[tag]
        core = true
      elsif ext_set.include?(tag)
        ext_set.delete(tag)
        metadata_key = @extended_tags[tag]
      else
        next
      end
      metadata[metadata_key] = {
        'value' => value.strip!.encode('UTF-8', @encoding),
        'core' => core
      }
    }
    left = last ? nil : leftovers(content)
    [metadata, left]
  end

end
