# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :instrument_rule do |f|
  f.unique_list
  f.exclusive_list
  f.indelible_list
  f.metadata_list
  f.visualisation_list
end
