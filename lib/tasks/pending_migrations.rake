require File.dirname(__FILE__) + '/pending_migrations.rb'
begin
  namespace :db do

    desc "show pending migrations"
    task :cat_pending_migrations => :environment do
      cat_pending_migrations
    end

  end
end
