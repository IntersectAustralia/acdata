Factory.define :user do |f|
  f.sequence(:login) { |n| "user #{n}" }
  f.sequence(:email) { |n| "user#{n}@test.com" }
  f.sequence(:supervisor_name) { |n| "supervisor #{n}" }
  f.sequence(:supervisor_email) { |n| "supervisor#{n}@test.com" }

end