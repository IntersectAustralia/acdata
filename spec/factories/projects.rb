# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :project do |f|
  f.sequence(:name) { |n| "project #{n}" }
  f.sequence(:description) { |n| "project description #{n}" }
  f.association :user
  #f.association :members, :factory => :user
end
