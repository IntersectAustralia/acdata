class CPBubblePoint < CPParseStrategy

  CORE_TAGS = [
      'Date & Time',
      'File',
      'SAMPLE ID',
      'FLUID',
      'BUBBLE POINT PRESSURE',
      'BUBBLE POINT PORE DIAMETER',
  ]

  EXTENDED_TAGS= [
      'SURFACE TENSION',
  ]

  SUPPLIED_TAGS = []

  TAG_MAPPINGS = {
      'FLUID' => 'Fluid',
      'BUBBLE POINT PRESSURE' => 'Bubble Point Pressure',
      'BUBBLE POINT PORE DIAMETER' => 'Bubble Point Pore Diameter',
      'SURFACE TENSION' => 'Surface Tension',
      'SAMPLE ID' => 'Sample ID'
  }

  def initialize
    super(CORE_TAGS, EXTENDED_TAGS, SUPPLIED_TAGS, TAG_MAPPINGS)
  end

  # No visualisation for Bubble Point Analyses
  def build(inputstream, output_path)
  end

end
