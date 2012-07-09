# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :settings do |f|
  f.handle_range_start "MyString"
  f.handle_range_end "MyString"
end