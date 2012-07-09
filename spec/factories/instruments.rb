# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :instrument do |f|
  f.sequence(:name) { |n| "Name#{n}"}
  f.association :instrument_rule, :factory => :instrument_rule
  f.instrument_class "Raman"
  f.is_available true
  f.instrument_file_types { |ft| [ft.association(:instrument_file_type)] }
end
