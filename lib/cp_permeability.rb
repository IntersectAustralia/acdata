class CPPermeability < CPParseStrategy
  include CPGraphBuilder

  CORE_TAGS = [
    'Date & Time',
    'FILE',
    'SAMPLE ID',
    'FLUID USED',
    'SAMPLE THICKNESS',
    'SAMPLE DIAMETER',
  ]

  EXTENDED_TAGS= [
    'FLUID VISCOSITY',
    'Average Frazier Number',
    'Frazier analysis',
  ]

  SUPPLIED_TAGS = []

  TAG_MAPPINGS = {
    'FILE' => 'File',
    'FLUID USED' => 'Fluid',
    'FLUID VISCOSITY' => 'Fluid Viscosity',
    'SAMPLE ID' => 'Sample ID',
    'SAMPLE THICKNESS' => 'Sample Thickness',
    'SAMPLE DIAMETER' => ' Sample Diameter',
  }

  def initialize
    super(CORE_TAGS, EXTENDED_TAGS, SUPPLIED_TAGS, TAG_MAPPINGS)
  end

  def get_graph_points(inputstream)
    x_points = []
    y_points = []
    inputstream.each do |line|
      break if line.match(/DPress\s+FRate\s+AR/)
    end
    inputstream.each do |line|
      next unless line.match(/\d+/)
      line.strip!
      values = line.split(/\s+/)
      dpress = values[0]
      ar = values[2]
      x_points << dpress.to_f
      y_points << ar.to_f
    end
    [x_points, y_points]
  end

  def set_axes_names(rdata)
    rdata.set_x_axis_name('DPress (psi/cc)')
    rdata.set_y_axis_name('AR (psi sec/cc)')
  end

end
