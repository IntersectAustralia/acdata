class SpFileParser < KeyValuePairFileParser

  HEADER_BUFFER = 10

  CORE_TAGS = ["Date/Time Entire Collection Started",
               "Sample Holder",
               "Laser Power",
               "Exposure Time",
               "Number of Exposures",
               "Sampling option",
               "Laser Wavelength"]

  EXTENDED_TAGS = ["RamanStation Instrument Serial Number",
                   "Spectrogrpah Installed",
                   "I2C Control Master",
                   "CCD Dimensions",
                   "Software Version",
                   "Selected Beampath (FIBRE1)",
                   "Sample Accessory",
                   "Sample Holder Columns",
                   "Sample Holder Rows",
                   "TEC Status",
                   "Laser Status",
                   "Description",
                   "Number of Background Exposures",
                   "Background acquired at",
                   "Background acquired once at start of Collect",
                   "Detector Temperature when Background was Acquired",
                   "Detector Set Temperature",
                   "Detector Temperature at start of Collection",
                   "Detector Temperature at end of Collection",
                   "Kinetic Mode",
                   "CCD Saturation checking activated",
                   "CCD Saturation value",
                   "Dynamic Range Useage",
                   "Region Sampled",
                   "Point Sampled",
                   "Current XYZ Position",
                   "Auto focus Option",
                   "Calibration Format",
                   "Data Spacing",
                   "Correction Type",
                   "Polynomials"]

  SUPPLIED_TAGS = []

  TAG_MAPPINGS = {"Date/Time Entire Collection Started" => "Date",
                  "Sampling option" => "Measurement Type",
                  "Laser Wavelength" => "Laser / Laser Wavelength",
                  "Number of Exposures" => "Accumulations"}

  def initialize
    super(CORE_TAGS, EXTENDED_TAGS, SUPPLIED_TAGS, TAG_MAPPINGS)
  end

  def do_file_specific_parsing(content_stream)
    metadata = {}
    regex = /Polynomials:\s*(.*)Apodize Data/m
    value = MultilineValueParser.get_multiline_value(content_stream, regex)
    metadata["Polynomials"] = {'value' => value, 'core' => false, 'supplied' => false} if value

    metadata
  end

  def recognise?(file_path)
    File.open(file_path) do |file|
      header = file.read(HEADER_BUFFER)
      !header.match(/^PEPE2D/).nil?
    end
  end

end
