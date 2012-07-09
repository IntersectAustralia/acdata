require File.join(File.dirname(__FILE__), '..', '/rda_grant_harvester.rb')

config = YAML.load_file("#{Rails.root.to_s}/config/acdata_config.yml")
env = ENV["RAILS_ENV"] || "development"
sensitive_data = YAML.load_file("#{config[env]['deploy_config_root']}/acdata_deploy_config.yml")
config[env].merge!(sensitive_data[env])

url = config[env]['ands']['grant_url']

namespace :rda_grants do

  desc "Retrieve and store RDA grants records from ANDS from the last week"
  task :retrieve => :environment do
    harvester = RdaGrantHarvester.new
    week_ago = Time.now - 7.day
    begin
      harvester.harvest(url, {:from_date => week_ago})
    rescue OAI::Exception::NoRecordsMatch
      puts "No new records"
    end
  end

  desc "Retrieve and store all RDA grants records from ANDS"
  task :retrieve_all => :environment do
    harvester = RdaGrantHarvester.new
    begin
      harvester.harvest(url, {:force => true})
    rescue OAI::Exception::NoRecordsMatch
      puts "No new records"
    end
  end

end
