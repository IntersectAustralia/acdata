class CapillaryPorometerFileHandler

  HANDLERS = {
    'BUBBLE POINT ANALYSIS' => 'CPBubblePoint',
    'PORE TABLE TEST ANALYSIS' => 'CPBubblePoint',
    'PERMEABILITY RESULTS'  => 'CPPermeability',
    'INTEGRITY TEST' => 'CPIntegrity',
    'CAPILLARY FLOW ANALYSIS' => 'CPCapFlow',
    'PRESSURE HOLD TEST ANALYSIS' => 'CPPressureHold'
  }

  def self.get_strategy(test_name)
    if HANDLERS.include?(test_name)
      Rails.logger.debug("Using strategy: #{HANDLERS[test_name]}")
      Object::const_get(HANDLERS[test_name]).new
    end
  end

  def self.get_test_type(input_stream)
    regex = Regexp.new(HANDLERS.keys.join('|'), Regexp::IGNORECASE)
    input_stream.each do |line|
      next unless line.match(/\S/)

      line.strip.match(/(#{regex})/i) do |match|
        return match[0].upcase
      end
    end
  end

  def self.get_test_type_from_file(file_path)
    raise "Implement in subclass"
  end

  def parse(src_file, encoding="ISO-8859-1")
    test_type = self.class.get_test_type_from_file(src_file)
    strategy = self.class.get_strategy(test_type)
    metadata = nil
    if strategy
      metadata = strategy.get_metadata(self.class.get_content(src_file))
      metadata['Test Method'] = {
        'value' => test_type,
        'core' => false,
        'supplied' => false
      }
    end
    metadata
  end

  def self.build(attachment)
    file_path = attachment.path
    strategy = get_strategy(get_test_type_from_file(file_path))
    dest = chart_file_path(attachment.dataset)
    strategy.build(get_content(file_path), dest) if strategy
  end

  def self.display_file(attachment)
    unless attachment.nil?
      chart_file_path(attachment.dataset)
    end
  end

  def self.visualisable?(dataset)
    test_name = test_type_from_metadata(dataset)
    test_name and
      HANDLERS.has_key?(test_name) and
      HANDLERS[test_name] != 'CPBubblePoint'
  end

  def self.test_type_from_metadata(dataset)
    test_type = dataset.metadata_values.find_by_key('Test Method')
    test_type.value unless test_type.nil?
  end

  private

  def self.chart_file_path(dataset)
    File.join(dataset.dataset_path, '_cp_chart.png')
  end

end

