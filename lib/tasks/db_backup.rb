require 'tempfile'

def db_backup(output_dir)
  db_config = Rails.configuration.database_configuration[Rails.env]

  raise 'i only know postgres' unless db_config['adapter'] == 'postgresql'

  db = db_config['database']
  host = db_config['host']
  database = db_config['database']
  username = db_config['username']
  password = db_config['password']

  pgpass_file = Tempfile.new('db_backup.pgpass')
  begin
    pgpass_file.puts "#{host}:*:#{database}:#{username}:#{password}"
    out_file = File.join(output_dir, "#{Time.now.strftime('%Y%m%d-%H%M%S')}.dump")
    puts `env PGPASSFILE=#{pgpass_file.path} pg_dump -U #{username} -h #{host} #{database} > #{out_file}`
  ensure
     pgpass_file.close
     pgpass_file.unlink   # deletes the temp file
  end

end

def trim_backups(log_dir, limit)
  # Deletes oldest logs leaving (at most) _limit_ backups

  lognames = Dir.entries(log_dir).find_all {|name| name =~ /^\d{8}-\d{6}.dump$/}
  lognames.sort! # files sorted by name => oldest first

  to_delete = lognames.slice(0...-limit)
  to_delete.each do |name|
    File.delete File.join(log_dir, name)
  end
end
