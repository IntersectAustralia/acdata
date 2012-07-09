require File.join(File.dirname(__FILE__), 'sample_data_populator.rb')
require File.join(File.dirname(__FILE__), 'test_ldap.rb')

begin  
  namespace :db do  
    desc "Populate the database with some sample data for testing"

    task :populate => :environment do
      unless %w(qa development test staging).include?(Rails.env)
        raise StandardError, "Error: Cannot populate in a non-development/qa/test environment!"
      end
      populate_data
      TestLDAP.new.populate_ldap
    end

    task :data_load => :environment do
      puts "Adding FOR codes"
      Rake::Task['data:for_codes:load'].invoke
      puts "Adding SEO codes"
      Rake::Task['data:seo_codes:load'].invoke
      puts "Adding Fluorescent Labels (Aperio Slide Scanning)"
      Rake::Task['data:fluorescent_labels:load'].invoke
      puts "Adding Aperio Slide Scanning Guidelines"
      Rake::Task['data:slide_guidelines:load'].invoke
      puts "Adding ANDS party records"
      Rake::Task['ands_parties:retrieve'].invoke
      puts "Adding RDA grants"
      Rake::Task['rda_grants:retrieve'].invoke
      puts "Adding MemRE properties"
      Rake::Task['memre:retrieve'].invoke
    end
  end

rescue LoadError  
  puts "Forgery is missing: please run bundle install"

end
