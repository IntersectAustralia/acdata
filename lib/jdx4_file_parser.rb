class JDX4FileParser < JDXFileParser

  CORE_TAGS = {
    'TITLE' => 'Title',
    'JCAMP-DX' => 'JCAMP-DX Version',
    'JCAMP_DX' => 'JCAMP-DX Version',
    'DATATYPE' => 'Data Type',
    'DATA TYPE' => 'Data Type',
    'DATE' => 'Date & Time',
    'LONGDATE' => 'Date & Time',
    'INSTRUMENT PARAMETERS' => 'Instrument Parameters (Group)',
    'XUNITS' => 'X-units',
    'YUNITS' => 'Y-units',
    'FIRSTX' => 'First X Value',
    'LASTX'  => 'Last X Value',
    'DELTAX' => 'X unit Spacing'
  }

  SUPPLIED_TAGS = [
    'Number of Scans',
    'ATR attachment'
  ]

  EXTENDED_TAGS = {
    'AUNITS' => 'Amplitude Factor',
    'BLOCKS' => 'No. of Blocks',
    'BP' => 'Boiling Point',
    'CASNAME' => 'CAS name',
    'CASREGISTRYNO' => 'CAS Registry No.',
    'CLASS' => 'Class',
    'CONCENTRATIONS' => 'Concentration',
    'DATAPROCESSING' => 'Data Processing',
    'DATATYPE' => 'Data Type',
    'DELTAR' => 'Optical Retardation Spacing',
    'DENSITY' => 'Density',
    'FIRSTA' => 'First Amplitude Value',
    'FIRSTR' => 'First Optical Retardation Value',
    'FIRSTY' => 'First Y Value',
    'LASTR' => 'Last Optical Retardation Value',
    'MAXA' => 'Maximum Amplitude Value',
    'MAXX' => 'Maximum X Value',
    'MAXY' => 'Maximum Y Value',
    'MINA' => 'Minimum Amplitude Value',
    'MINX' => 'Minimum X Value',
    'MINY' => 'Minimum Y Value',
    'MOLFORM' => 'Molecular Formula',
    'MP' => 'Melting Point',
    'MW' => 'Molecular Weight',
    'NAMES' => 'Common Name',
    'NPOINTS' => 'Number of points in data table',
    'ORIGIN' => 'Origin',
    'OWNER' => 'Owner',
    'PATHLENGTH' => 'Path length',
    'PEAKASSIGNMENTS' => 'Peak Assignments',
    'PEAKTABLE' => 'Peak Table',
    'PRESSURE' => 'Pressure',
    'REFRACTIVEINDEX' => 'Refractive Index',
    'RESOLUTION' => 'Resolution (X units)',
    'RFACTOR' => 'Optical Retardation Scale Factor',
    'RUNITS' => 'Optical Retardation Units',
    'SAMPLEDESCRIPTION' => 'Sample Description',
    'SAMPLINGPROCEDURE' => 'Sampling Procedure',
    'SPECTROMETERDATASYSTEM' => 'Spectrometer',
    'SPECTROMETER/DATA\ SYSTEM' => 'Spectrometer',
    'STATE' => 'State',
    'TEMPERATURE' => 'Temperature',
    'TIME' => 'Time',
    'XFACTOR' => 'X Value Scale Factor',
    'XLABEL' => 'X-axis Label',
    'XUNITS' => 'X Value Units',
    'YFACTOR' => 'Y Value Scale Factor',
    'YLABEL' => 'Y-axis Label',
    'YUNITS' => 'Y Value Units',
    'ZPD' => 'Zero Path Difference',
  }

  def recognise?(file_path)
    version = self.class.version(file_path)
    version.nil? ? false : !version.match(/^4\./).nil?
  end

  def initialize
    super(CORE_TAGS, EXTENDED_TAGS, SUPPLIED_TAGS)
  end
end
