# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :activity do |f|
  f.sequence(:project_name) { |n| "Project Name #{n}"}
  f.sequence(:funding_sponsor) { |n| "Funding Sponsor #{n}"}
  f.sequence(:project_id) {|n| "#{n}" }
end