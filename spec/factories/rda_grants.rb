# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :rda_grant do |f|
  f.sequence(:primary_name) {|n| "Grant #{n}"}
  f.group "Australian Research Council"
end