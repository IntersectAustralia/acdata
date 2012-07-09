class NMRHarvester

  require 'net/ftp'
  require 'net/ftp/list'

  def self.fetch_datasets(ftp, instruments, users, tmp_dir, date_after=nil)
    Rails.logger.auto_flushing = true
    return if instruments.empty?
    return if users.empty?
    raise "date_after must by of type Time" unless date_after.nil? or date_after.is_a?(Time)

    unless File.exists?(tmp_dir)
      FileUtils.mkdir(tmp_dir)
    end

    instruments.each do |instrument|
      instrument_name = self.get_instrument_name(instrument)
      begin
        Rails.logger.debug("NMRHarvester: cd #{instrument_name}/data")
        ftp.chdir("#{instrument_name}/data")
      rescue Exception => e
        $stderr.puts(e.message)
        $stderr.puts(e.backtrace.join("\n"))
        ftp.chdir('/')
        next
      end
      nmr_user_dirs = ftp.nlst
      users.each do |user|
        user_dir = user.nmr_username.downcase
        next unless nmr_user_dirs.include?(user_dir)
        next unless ftp.nlst("#{user_dir}").include?("nmr")

        Rails.logger.debug("NMRHarvester: Examining #{user_dir}")
        begin
          ftp.chdir("#{user_dir}/nmr")
          sample_dirs = self.wanted_dirs(ftp.list, date_after)
          Rails.logger.debug("NMRHarvester: wanted dirs #{sample_dirs}")
          sample_dirs.each do |dir|
            dest_dir = File.join(tmp_dir, instrument.id.to_s, user.id.to_s, dir)
            unless sample_dirs.empty?
              FileUtils.mkdir_p(dest_dir)
            end
            ftp.get_dir(dest_dir, dir)
          end 
        rescue Exception => e
          $stderr.puts(e.message)
          $stderr.puts(e.backtrace.join("\n"))
        end
        ftp.chdir('../..')
      end
      ftp.chdir('../..')
    end
    ftp.close
  end

  def self.wanted_dirs(ftp_list, date_after)
    list = []
    ftp_list.each do |e|
      entry = Net::FTP::List.parse(e)
      if entry.basename =~ /^[\w-]+$/
        if (date_after.nil? or entry.mtime >= date_after)
          list << entry.basename 
        end
      end
    end
    list
  end

  def self.get_instrument_name(instrument)
    instrument.name.match(/\((.+?)\)/) do |m|
      m.captures.first
    end
  end

  def self.get_instruments
    Instrument.where(:instrument_class => 'NMR')
  end

  def self.get_users
    User.where(:nmr_username.ne => nil, :nmr_enabled => true)
  end

  def self.connect(host, ftp_user, ftp_pass)
    ftp = Net::FTP.new(host)
    ftp.passive = true
    ftp.login(ftp_user, ftp_pass)
    raise "Not logged in" if ftp.closed?
    ftp.binary = true
    ftp
  end

end
