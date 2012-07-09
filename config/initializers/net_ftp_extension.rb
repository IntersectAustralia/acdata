module Net

  class FTP
    require 'net/ftp/list'
  # Recursively pull down files
  # :since => true - only pull down files newer than their local counterpart, or with a different filesize
  # :since => Time.now - only pull down files newer than the supplied timestamp, or with a different filesize
  # :delete => Remove local files which don't exist on the FTP server
  # If a block is supplied then it will be called to remove a local file
  
    def get_dir(localpath, remotepath, options = {}, &block)
Rails.logger.debug("FTP #{remotepath} into #{localpath}")

      todelete = Dir.glob(File.join(localpath, '*'))
      ignore_pattern = Regexp.new(options.has_key?('ignore') ? options['ignore'] : '^$')
      
      tocopy = []
      recurse = []

Rails.logger.debug("FTP cwd=#{pwd}")

      list(remotepath) do |e|
        entry = Net::FTP::List.parse(e)
Rails.logger.debug("FTP entry: #{entry}")
        
        paths = [ File.join(localpath, entry.basename), "#{remotepath}/#{entry.basename}".gsub(/\/+/, '/') ]

        if entry.basename.match(ignore_pattern)
          Rails.logger.debug("FTP: skipping #{entry.basename}: matches ignore pattern")
          next
        end

        if entry.dir?
          next if entry.basename =~ /^\.\.?$/
          recurse << paths
        elsif entry.file?
          if options[:since] == :src
            tocopy << paths unless File.exist?(paths[0]) and entry.mtime < File.mtime(paths[0]) and entry.filesize == File.size(paths[0])
          elsif options[:since].is_a?(Time)
            tocopy << paths unless entry.mtime < options[:since] and File.exist?(paths[0]) and entry.filesize == File.size(paths[0])
          else
            tocopy << paths
          end
        end
        todelete.delete paths[0]
      end
      
      tocopy.each do |paths|
        localfile, remotefile = paths
        begin
          get(remotefile, localfile)
          #log "Pulled file #{remotefile}"
        rescue Net::FTPPermError
          #log "ERROR READING #{remotefile}"
          raise Net::FTPPermError unless options[:skip_errors]
        end        
      end
      
      recurse.each do |paths|
        localdir, remotedir = paths
Rails.logger.debug("FTP recursing: #{paths}")
        Dir.mkdir(localdir) unless File.exist?(localdir)
        get_dir(localdir, remotedir, options, &block)
      end
      
      if options[:delete]
        todelete.each do |p|
          block_given? ? yield(p) : FileUtils.rm_rf(p)
          #log "Removed path #{p}"
        end
      end
      
    end

  end
end
