class CPIntegrity < CPParseStrategy
  include CPGraphBuilder

  CORE_TAGS = [
    'Date & Time',
    'File',
    'SAMPLE ID',
    'FLUID',
  ]

  EXTENDED_TAGS= [
    'SURFACE TENSION',
  ]

  SUPPLIED_TAGS = []

  TAG_MAPPINGS = {
    'FLUID' => 'Fluid',
    'SAMPLE ID' => 'Sample ID',
    'SURFACE TENSION' => 'Surface Tension',
  }

  def initialize
    super(CORE_TAGS, EXTENDED_TAGS, SUPPLIED_TAGS, TAG_MAPPINGS)
  end

  def get_graph_points(inputstream)
    x_points = []
    y_points = []
    inputstream.each do |line|
      break if line.match(/PRESSURE\s+DIAMETER\s+WET\s+FLOW/)
    end
    inputstream.each do |line|
      next unless line.match(/\d+/)
      line.strip!
      values = line.split(/\s+/)
      diameter = values[1]
      wet_flow = values[2]
      x = diameter.to_f
      y = wet_flow.to_f
      x_points << x
      y_points << y
    end
    [x_points, y_points]
  end

  def set_axes_names(rdata)
    rdata.set_x_axis_name('Diameter (microns)')
    rdata.set_y_axis_name('Wet Flow (L/min)')
  end

end
