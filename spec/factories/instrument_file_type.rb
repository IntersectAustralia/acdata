# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :instrument_file_type do |f|
  f.name "File Type 1"
  f.filter
  f.parser_name nil
end
