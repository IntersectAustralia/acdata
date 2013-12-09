require File.dirname(__FILE__) + '/db_backup.rb'
require 'fileutils'

begin  
  namespace :db do  

    desc "Backup the database"
    task :backup => :environment do  
      backup_dir = Rails.root.join 'db_dumps'
      FileUtils.mkdir_p backup_dir

      db_backup backup_dir
    end

    desc "Backup the database"
    task :trim_backups => :environment do
      backup_dir = Rails.root.join 'db_dumps'
      at_most = 5

      trim_backups backup_dir, at_most
    end
  end  
end
