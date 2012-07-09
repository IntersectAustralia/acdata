class CPPressureHold < CPParseStrategy
  include CPGraphBuilder

  CORE_TAGS = [
    'Date & Time',
    'File',
    'Sample ID',
    'GAS',
  ]

  EXTENDED_TAGS= [
  ]

  SUPPLIED_TAGS = []

  TAG_MAPPINGS = {
    'GAS' => 'Fluid'
  }

  def initialize
    super(CORE_TAGS, EXTENDED_TAGS, SUPPLIED_TAGS, TAG_MAPPINGS)
  end

  def get_graph_points(inputstream)
    x_points = []
    y_points = []
    inputstream.each do |line|
      break if line.match(/----/)
    end
    inputstream.each do |line|
      break if line.match(/----/)
      line.strip!
      values = line.split(/\s+/)
      time = values[1]
      dp_dt = values[2]
      x = time.to_f
      y = dp_dt.to_f
      x_points << x
      y_points << y
    end
    [x_points, y_points]
  end

  def set_axes_names(rdata)
    rdata.set_x_axis_name('Time (sec)')
    rdata.set_y_axis_name('dP/dt (*1E-3)')
  end
end
