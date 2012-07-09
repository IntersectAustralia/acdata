require File.dirname(__FILE__) + '/test_ldap.rb'

begin  
  namespace :ldap do  
    desc "Populate the test LDAP with initial users"

    task :initial_users => :environment do
      TestLDAP.new(Rails.env).populate_ldap('initial_users')
    end
  end
end
