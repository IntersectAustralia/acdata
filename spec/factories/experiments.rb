# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :experiment do |f|
  f.sequence(:name) { |n| "exp#{n}"}
  f.association :project
end