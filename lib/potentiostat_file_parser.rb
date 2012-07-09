class PotentiostatFileParser < KeyValuePairFileParser

  HEADER_BUFFER = 1000

  CORE_TAGS = [
      "Date",
      "Time",
      "Experiment Mode",
      "Start potential (V)",
      "First vertex potential (V)",
      "Second vertex potential (V)",
      "Step potential (V)",
      "Scan rate (V/s)",
      "Equilibration time (s)",
      "Number of Data Points",
      "Electrolyte Medium",
      "Concentration of the Ionic Medium",
      "Cathode",
      "Anode",
      "Reference Electrode"
  ]

  EXTENDED_TAGS= []

  SUPPLIED_TAGS = [
      "Electrolyte Medium",
      "Concentration of the Ionic Medium",
      "Cathode",
      "Anode",
      "Reference Electrode"
  ]

  TAG_MAPPINGS = {"Exp. Conditions" => "Experiment Mode"}

  def initialize
    super(CORE_TAGS, EXTENDED_TAGS, SUPPLIED_TAGS, TAG_MAPPINGS)
  end

  def recognise?(file_path)
    File.open(file_path) do |file|
      header = file.read(HEADER_BUFFER)
      !header.match(/Start\spotential/).nil?
    end
  end

  def parse(path, encoding="ISO-8859-1")
    metadata = super

    if valid?(path, metadata)
      metadata
    end
  end

  def valid?(path, metadata)
    expected_points = metadata["Number of Data Points"]['value']
    unless expected_points
      raise "#{File.basename(path)} is not a complete Potentiostat file"
    end
    file = File.open(path, "r:ISO-8859-1")
    actual_points = data_point_count(file)
    if expected_points.to_i != actual_points
      raise "Number of data points doesn't match expectation (expected: #{expected_points}, got: #{actual_points})"
    end

    true
  end

  def do_file_specific_parsing(iostream)
    metadata = {}
    regex = /Exp. Conditions:\s*(.+)/
    value = MultilineValueParser.get_multiline_value(iostream, regex)
    unless value.nil?
      metadata["Experiment Mode"] = {
          'value' => value.strip,
          'core' => true,
          'supplied'=> false
      }
    end
    metadata
  end

  private
  def data_point_count(file)
    points_count = -1
    points_regex = /Potential\s+(?:Scan\s+\d+\s*)+(.+)/m

    points = MultilineValueParser.get_multiline_value(file, points_regex)
    if points
      points_count = points.split(/\n/).size
    end
    points_count
  end
end
