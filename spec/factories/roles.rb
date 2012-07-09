Factory.define :role do |f|
  f.sequence(:name) { |n| "role-#{n}" }
end
