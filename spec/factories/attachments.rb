# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :attachment do |f|
  f.sequence(:filename) { |n| "attachment #{n}" }
  f.format "file"
  f.association :dataset
  f.association :instrument_file_type
end
