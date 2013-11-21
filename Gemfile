source 'http://rubygems.org'

# https://github.com/brendan/rack/commit/8f7fcf0fdd9fd99aa529159d05c63dc2b0bfe08a
# rails 3.0.x (actionpack) depends on rack 1.2 whereas 1.3 is the first
# version that fixes the issue above
gem 'rack', :git => "https://github.com/IntersectAustralia/rack.git", :branch => "rack-1.2"

gem 'rails', '3.0.19'
gem 'rake', '0.8.7', :require => false

group :development do
  gem "rails3-generators"
  gem "create_deployment_record", git: 'https://github.com/IntersectAustralia/create_deployment_record.git'
end

group :test do
  # cucumber gems
  gem "cucumber"
  gem "cucumber-rails", '1.1.1', :require => false
  gem "selenium-webdriver", "~> 2.35.1"
end

group :development, :test do
  gem "rspec-rails"
  gem "factory_girl_rails"
  gem "shoulda"

  gem "capybara"
  gem "database_cleaner"
  gem "spork", "> 0.9.0.rc"
  gem "launchy" # So you can do "Then show me the page" in cucumber

  gem "escape_utils"
  gem "email_spec"
  gem "fakeweb", :require => false
  gem "webmock", :require => false
end

group :development, :test, :qa do
  gem "faker"
  gem "ladle"
end

gem 'acdata-dataset-api', :git => "https://github.com/IntersectAustralia/acdata-dataset-api.git", :require => false
gem 'nokogiri'
gem 'pg'
gem "rubyzip", :require => 'zip/zip'
gem "decent_exposure"
gem 'meta_search'
gem 'meta_where'
gem "jquery-rails"
gem "devise", '1.5.4'
gem "nested_form"
gem "cancan"
gem "capistrano-ext"
gem "capistrano"
gem "rvm-capistrano"
gem "net-ldap"
gem "devise_ldap_authenticatable"
gem "rails3-jquery-autocomplete"
gem 'acts_as_singleton'
gem 'whoops_rails_logger', git: 'https://github.com/IntersectAustralia/whoops_rails_logger.git'
gem "file-temp", :require => 'file/temp'
gem "paperclip"
gem "remotipart" #ajax file uploads
gem "gd2-ffij" #image processing library
gem 'spreadsheet'
gem 'rchart', '~> 2.0.4'
gem "exifr" #jpeg exif parser
gem 'whenever', :require => false
gem 'net-ftp-list', :require => false
gem 'highline', :require => false
gem 'prawn'
gem 'mechanize'
