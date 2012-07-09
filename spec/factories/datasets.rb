# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :dataset do |f|
  f.sequence(:name) { |n| "dataset #{n}"}
  f.association :sample
  f.association :instrument
end
