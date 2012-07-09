# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :ands_publishable do |f|
  f.collection_name "MyString"
  f.collection_description "MyString"
  f.address APP_CONFIG['default_address']
  f.access_rights "MyString"
  f.association :project
  f.moderator_id 1
end