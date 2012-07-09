# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :sample do |f|
  f.name "Sample"
#  f.association :samplable, :factory => :experiment
  f.association :samplable, :factory => :project
#  f.samplable_id 1
#  f.samplable_type "Project"
end
