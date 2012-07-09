# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :eln_export do |f|
  f.sequence(:title) { |n| "Title #{n}" }
  f.sequence(:blog_name) { |n| "Blog #{n}" }
  f.sequence(:section) { |n| "Section #{n}" }
end