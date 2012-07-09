require File.join(File.dirname(__FILE__), '..', '/memre_harvester.rb')

config = YAML.load_file("#{Rails.root.to_s}/config/acdata_config.yml")
env = ENV["RAILS_ENV"] || "development"
sensitive_data = YAML.load_file("#{config[env]['deploy_config_root']}/acdata_deploy_config.yml")
config[env].merge!(sensitive_data[env])

url = config[env]['memre']['base_url']

namespace :memre do

  desc "Add or update measurement properties from MemRE wikiDB"
  task :retrieve => :environment do
    MemreHarvester.fetch_and_store_properties(url)
  end

  desc "Refresh measurement properties from MemRE wikiDB (deletes current records)"
  task :refresh => :environment do
    MemreHarvester.fetch_and_store_properties(url, true)
  end

end
