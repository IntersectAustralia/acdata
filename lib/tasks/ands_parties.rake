require File.join(File.dirname(__FILE__), '..', '/ands_party_harvester.rb')

config = YAML.load_file("#{Rails.root.to_s}/config/acdata_config.yml")
env = ENV["RAILS_ENV"] || "development"
sensitive_data = YAML.load_file("#{config[env]['deploy_config_root']}/acdata_deploy_config.yml")
config[env].merge!(sensitive_data[env])

url = config[env]['ands']['party_url']

namespace :ands_parties do  

  desc "Retrieve and store party records from ANDS"
  task :retrieve => :environment do
    party_harvester = AndsPartyHarvester.new
    week_ago = Time.now - 7.day
    begin
      party_harvester.harvest(url, {:from_date => week_ago})
    rescue OAI::Exception::NoRecordsMatch
    end
  end

  desc "Force add party records to DB from ANDS XML parties file"
  task :retrieve_all => :environment do
    party_harvester = AndsPartyHarvester.new
    party_harvester.fetch_and_store_party_records(url, {:force => true})
  end

end
