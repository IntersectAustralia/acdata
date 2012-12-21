require_relative '../aperio_harvester.rb'

namespace :aperio do
  desc "Harvest Aperio information"
  task :harvest => :environment do
    Rails.logger.auto_flushing = true
    config = {}
    config[:base_url] = APP_CONFIG['aperio']['base_url']
    config[:project_list_url] = APP_CONFIG['aperio']['project_list_url']
    config[:export_data_url] = APP_CONFIG['aperio']['export_data_url']
    config[:slide_thumbnail_url] = APP_CONFIG['aperio']['slide_thumbnail_url']
    config[:label_thumbnail_url] = APP_CONFIG['aperio']['label_thumbnail_url']
    config[:image_url] = APP_CONFIG['aperio']['image_url']
    config[:username] = APP_CONFIG['aperio']['username']
    config[:password] = APP_CONFIG['aperio']['password']
    config[:instrument_name] = APP_CONFIG['aperio']['instrument_name']
    config[:slide_file_type] = APP_CONFIG['aperio']['slide_file_type']
    config[:label_file_type] = APP_CONFIG['aperio']['label_file_type']
    config[:files_root] = APP_CONFIG['files_root']

    Rails.logger.info("Connecting to Aperio: #{Time.now}")
    AperioHarvester.harvest(config)
  end
end

