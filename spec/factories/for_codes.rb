# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :for_code do |f|
  f.sequence(:name) { |n| "for code #{n}"}
  f.sequence(:code) { |n| "FOR#{n}"}
end