class CPCapFlow < CPParseStrategy
  include CPGraphBuilder

  CORE_TAGS = [
    'Date & Time',
    'File',
    'Operator',
    'SAMPLE ID',
    'LOT NUMBER',
    'FLUID',
    'Type of test',
    'SAMPLE THICKNESS',
    'SAMPLE DIAMETER',
    'BUBBLE POINT PRESSURE',
    'BUBBLE POINT PORE DIAMETER',
    'MEAN FLOW PORE PRESSURE',
    'MEAN FLOW PORE DIAMETER',
  ]

  EXTENDED_TAGS= [
    'SURFACE TENSION',
    'Frazier analysis',
    'TORTUOSITY',
    'Wet Parameter',
    'Dry Parameter',
    'Lohm Table',
    'Hardware Serial Number',
    'STANDARD DEVIATION OF AVG. PORE DIAMETER'
  ]

  SUPPLIED_TAGS = []

  TAG_MAPPINGS = {
    'FLUID' => 'Fluid',
    'SAMPLE ID' => 'Sample ID',
    'SAMPLE THICKNESS' => 'Sample Thickness',
    'SAMPLE DIAMETER' => ' Sample Diameter',
    'BUBBLE POINT PRESSURE' => 'Bubble Point Pressure',
    'BUBBLE POINT PORE DIAMETER' => 'Bubble Point Pore Diameter',
    'LOT NUMBER' => 'Lot Number',
    'MEAN FLOW PORE PRESSURE' => 'Mean Flow Pore Pressure',
    'MEAN FLOW PORE DIAMETER' => 'Mean Flow Pore Diameter',
    'SURFACE TENSION' => 'Surface Tension',
    'TORTUOSITY' => 'Tortuosity',
    'STANDARD DEVIATION OF AVG. PORE DIAMETER' => 'Std. Deviation of Avg. Pore Diameter'
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
      break if line.match(/-------------/)
      next unless line.match(/\d+/)
      line.strip!
      values = line.split(/\s+/)
      diameter = values[1]
      pore_dist = values[6]
      if pore_dist.nil?
        pore_dist = 0
      end
      x = diameter.to_f
      y = pore_dist.to_f
      x_points << x
      y_points << y
    end
    [x_points, y_points]
  end

  def set_axes_names(rdata)
    rdata.set_x_axis_name('Diameter (microns)')
    rdata.set_y_axis_name('Pore (dist)')
  end

end
