def cat_pending_migrations
  migrations = pending_migrations
  puts "#{migrations.length} pending migration(s)"
  migrations.each do |migration|
    content = File.read migration.filename
    puts migration.filename
    puts content
  end

  filenames = migrations.map(&:filename)
end

def pending_migrations
  ActiveRecord::Migrator.new(:up, 'db/migrate').pending_migrations
end
