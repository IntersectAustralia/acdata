class TimeFormats
  # W3CDTF format for rif-cs
  Time::DATE_FORMATS[:w3cdtf] = lambda { |time| time.strftime("%Y-%m-%dT%H:%M:%S#{time.formatted_offset}") }
end