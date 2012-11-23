require_relative '../nmr_harvester.rb'
require_relative '../nmr_importer.rb'

namespace :nmr do  
  desc "Fetch NMR sample files from FTP site created in the last 5 minutes"
  task :harvest_daily => :environment do
    date_after = Time.now - 5.minutes
    harvest(date_after)
  end

  desc "Fetch NMR sample files from FTP site created in the last week"
  task :harvest_weekly => :environment do
    date_after = Time.now - 7.days
    harvest(date_after)
  end

  task :import => :environment do
    tmp_dir  = APP_CONFIG['nmr']['download_dir']
    NMRImporter.import(tmp_dir)
  end

  task :force_import => :environment do
    tmp_dir  = APP_CONFIG['nmr']['download_dir']
    NMRImporter.import(tmp_dir, false)
  end
end

def harvest(date_after)
  host = APP_CONFIG['nmr']['ftp_host']
  ftp_user = APP_CONFIG['nmr']['ftp_user']
  ftp_pass = APP_CONFIG['nmr']['ftp_password']
  tmp_dir  = APP_CONFIG['nmr']['download_dir']
  ftp = NMRHarvester.connect(host, ftp_user, ftp_pass)
  instruments = NMRHarvester.get_instruments
  users = NMRHarvester.get_users
  NMRHarvester.fetch_datasets(ftp, instruments, users, tmp_dir, date_after)
end
