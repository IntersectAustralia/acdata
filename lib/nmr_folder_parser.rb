class NmrFolderParser < KeyValuePairFileParser

  CORE_TAGS = [

      'Sample Name',
      '##$SOLVENT',
      '##$TE',
      '##$SF',
      '##$NS',
      '##$RG',
      '##$NUC1',
      '##$SW',
      "User ID",
      "Experiment ID",
      "Date and Time",
      "Delay Time"

  ]

  EXTENDED_TAGS= [

      #Experiment
      '##$PULPROG',
      '##$AQ_mod',
      '##$TD',
      '##$DS',

      #Width
      '##$SW_h',
      '##$FW',

      #Reference
      '##$SI',
      '##$OFFSET',
      '##$STSR',
      '##$SPECTYP',

      #'##$NUC1',
      '##$NUC2',
      '##$NUC3',
      '##$NUC4',
      '##$NUC5',
      '##$NUC6',
      '##$NUC7',
      '##$NUC8',

      '##$O1',
      '##$O2',
      '##$O3',
      '##$O4',
      '##$O5',
      '##$O6',
      '##$O7',
      '##$O8',

      '##$SFO1',
      '##$SFO2',
      '##$SFO3',
      '##$SFO4',
      '##$SFO5',
      '##$SFO6',
      '##$SFO7',
      '##$SFO8',

      '##$BF1',
      '##$BF2',
      '##$BF3',
      '##$BF4',
      '##$BF5',
      '##$BF6',
      '##$BF7',
      '##$BF8',

      #Phase Correction
      '##$PHC0',
      '##$PHC1',
      '##$PH_mod',

      #Baseline Correction
      '##$ABSG',
      '##$ABSF1',
      '##$ABSF2',
      '##$BCFW',
      '##$COROFFS'

  ]

  SUPPLIED_TAGS = []

  TAG_MAPPINGS = {
      '##$TI' => "Sample Name",
      '##$SOLVENT' => "Solvent",
      '##$TE' => "Temperature",
      '##$SF' => "Frequency",
      '##$NS' => "Number of Scans",
      '##$RG' => "Receiver Gain",
      '##$NUC1' => "Nucleus",

      #Experiment
      '##$PULPROG' => "Pulse Program",
      '##$AQ_mod' => "Acquisition mode",
      '##$TD' => "Size of fid",
      '##$DS' => "Number of Dummy Scans",

      #Width
      '##$SW' => "Spectral Width (ppm)",
      '##$SW_h' => "Spectral Width (hz)",
      '##$FW' => "Filter Width (hz)",

      #Reference
      '##$SI' => "Size of Real Spectrum",
      '##$OFFSET' => "Low field Limit of Spectrum",
      '##$STSR' => "Spectrum reference frequency",
      '##$SPECTYP' => "Type of Spectrum",

      #"Transmitter Frequency Offset (hz)"
      '##$NUC1' => "Observe Nucleus 1",
      '##$NUC2' => "Observe Nucleus 2",
      '##$NUC3' => "Observe Nucleus 3",
      '##$NUC4' => "Observe Nucleus 4",
      '##$NUC5' => "Observe Nucleus 5",
      '##$NUC6' => "Observe Nucleus 6",
      '##$NUC7' => "Observe Nucleus 7",
      '##$NUC8' => "Observe Nucleus 8",

      '##$O1' => "Transmitter Frequency Offset 1 (ppm)",
      '##$O2' => "Transmitter Frequency Offset 2 (ppm)",
      '##$O3' => "Transmitter Frequency Offset 3 (ppm)",
      '##$O4' => "Transmitter Frequency Offset 4 (ppm)",
      '##$O5' => "Transmitter Frequency Offset 5 (ppm)",
      '##$O6' => "Transmitter Frequency Offset 6 (ppm)",
      '##$O7' => "Transmitter Frequency Offset 7 (ppm)",
      '##$O8' => "Transmitter Frequency Offset 8 (ppm)",

      '##$SFO1' => "Transmitter Frequency 1 (MHz)",
      '##$SFO2' => "Transmitter Frequency 2 (MHz)",
      '##$SFO3' => "Transmitter Frequency 3 (MHz)",
      '##$SFO4' => "Transmitter Frequency 4 (MHz)",
      '##$SFO5' => "Transmitter Frequency 5 (MHz)",
      '##$SFO6' => "Transmitter Frequency 6 (MHz)",
      '##$SFO7' => "Transmitter Frequency 7 (MHz)",
      '##$SFO8' => "Transmitter Frequency 8 (MHz)",

      '##$BF1' => "Basic Transmitter Frequency 1 (MHz)",
      '##$BF2' => "Basic Transmitter Frequency 2 (MHz)",
      '##$BF3' => "Basic Transmitter Frequency 3 (MHz)",
      '##$BF4' => "Basic Transmitter Frequency 4 (MHz)",
      '##$BF5' => "Basic Transmitter Frequency 5 (MHz)",
      '##$BF6' => "Basic Transmitter Frequency 6 (MHz)",
      '##$BF7' => "Basic Transmitter Frequency 7 (MHz)",
      '##$BF8' => "Basic Transmitter Frequency 8 (MHz)",

      #Phase Correction
      '##$PHC0' => "0th Order Correction for pk",
      '##$PHC1' => "1st Order Correction for pk",
      '##$PH_mod' => "Phasing Modes",

      #Baseline Correction
      '##$ABSG' => "Degree of polynomial for abs",
      '##$ABSF1' => "Left limit for absf",
      '##$ABSF2' => "Right Limit for absf, abs 1, abs2",
      '##$BCFW' => "Filter width for bc",
      '##$COROFFS' => "Correction Offset"
  }

  def initialize
    super(CORE_TAGS, EXTENDED_TAGS, SUPPLIED_TAGS, TAG_MAPPINGS)
  end

  def parse(folder_path, encoding="ISO-8859-1")
    metadata = {}

    acqu_path = File.join(folder_path, 'acqus')
    proc_path = File.join(folder_path, 'pdata', '1', 'proc')

    acqu_file = File.open(acqu_path, "r:#{encoding}")
    proc_file = File.open(proc_path, "r:#{encoding}")

    acqu_file.each do |line|
      if line =~ @regex
        matches = line.scan(@regex)
        key = matches[0][0]
        value = matches[0][1]
        value = extract(value) if value
        if !value.eql?("off")
          mapped_key = map_key(key)
          metadata[mapped_key] = make_value(mapped_key, value)
        end
      end
    end

    proc_file.each do |line|
      if line =~ @regex
        matches = line.scan(@regex)
        key = matches[0][0]
        value = matches[0][1]
        if value
          value = extract(value)
          mapped_key = map_key(key)
          metadata[mapped_key] = make_value(mapped_key, value)
        end
      end
    end

    extra_metadata = do_file_specific_parsing(folder_path)
    metadata.merge!(extra_metadata) unless extra_metadata.nil?

    metadata
  end

  def extract(value)
    result = value.strip
    result = result.gsub(/[<>]/, "")
    result
  end

  def do_file_specific_parsing(folder_path)
    metadata = {}
    acqu_path = File.join(folder_path, 'acqus')
    acqu_file = File.open(acqu_path, "r:ISO-8859-1")

    content = acqu_file.read

    content.match(/\$\$\s(.*?)\$AMP/mx) { |matches|
      value = matches.captures.first
      experiment_id = value[/nmr\/([^\/]+)\//,1]
      user_id = nil
      if experiment_id.present?
        user_id = experiment_id[/^([a-z]{3})-?\d+$/,1]
      end
      date_time = value[/\d{4}\-\d{2}\-\d{2}.*?\+\d{4}/]
      if date_time.nil?
        date_time = value[/[a-z]{3}\s+[a-z]{3}\s+\d{1,2}\s+\d{2}\:\d{2}\:\d{2}\s+\d{4}.*?\)/i]
      end
      metadata["Experiment ID"] = make_value("Experiment ID", experiment_id)
      metadata["User ID"] = make_value("User ID", user_id)
      metadata["Date and Time"] = make_value("Date and Time", date_time)
    }

    # Array of numbers. Should be the second one.
    # E.g.
    #
    # ##$D= (0..63)
    # 0 2 0.00345 0 0 0 0 0 0 0 0 0.03 2e-005 3e-006 0 0 0.0002 0 0 0 0 0 0 0
    #
    # We want the number "2"
    content.match(/D=.*\n\d+\s(\d+)\s/) { |matches|
      metadata["Delay Time"] = make_value("Delay Time", matches.captures.first)
    }

    title = nil
    title_path = File.join(folder_path, 'pdata', '1', 'title')
    if File.exists?(title_path) and !File.zero?(title_path)
      title_file = File.open(title_path, "r:ISO-8859-1")
      title = title_file.readline
      title.strip!
    end
    metadata['Sample Name'] = make_value('Sample Name', title)

    metadata
  end

  def recognise?(file_path)
    if File.directory?(file_path)
      File.exists?(File.join(file_path, 'acqu')) and
          File.exists?(File.join(file_path, 'pdata', '1', 'proc'))
    end
  end

  private

  def is_core?(value)
    @tag_mappings.values.include?(value) ? @core_tags.include?(@tag_mappings.key(value)) : super(value)
  end

  def is_supplied?(value)
    @supplied_tags.include?(value)
  end

  def make_value(key, value)
    if value
      {
          'value' => value,
          'core' => is_core?(key),
          'supplied' => is_supplied?(key)
      }
    end
  end

end
