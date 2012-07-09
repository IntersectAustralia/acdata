#Monkeypatching rubyzip gem to force utf-8

Zip::ZipEntry.class_eval do
  def write_local_entry(io) #:nodoc:all
    @localHeaderOffset = io.tell

    io <<
        [Zip::ZipEntry::LOCAL_ENTRY_SIGNATURE,
         Zip::ZipEntry::VERSION_NEEDED_TO_EXTRACT, # version needed to extract
       ## LINE EDITED TO ACCOMMODATE UTF-8
         0b100000000000, # @gp_flags                  ,
       ##
         @compression_method,
         @time.to_binary_dos_time, # @lastModTime              ,
         @time.to_binary_dos_date, # @lastModDate              ,
         @crc,
         @compressed_size,
         @size,
         @name ? @name.bytesize : 0,
         @extra ? @extra.local_length : 0].pack('VvvvvvVVVvv')
    io << @name
    io << (@extra ? @extra.to_local_bin : "")
  end

  def write_c_dir_entry(io) #:nodoc:all
    case @fstype
      when Zip::ZipEntry::FSTYPE_UNIX
        ft = nil
        case @ftype
          when :file
            ft = 010
            @unix_perms ||= 0644
          when :directory
            ft = 004
            @unix_perms ||= 0755
          when :symlink
            ft = 012
            @unix_perms ||= 0755
          else
            raise ZipInternalError, "unknown file type #{self.inspect}"
        end

        @externalFileAttributes = (ft << 12 | (@unix_perms & 07777)) << 16
    end

    io <<
        [Zip::ZipEntry::CENTRAL_DIRECTORY_ENTRY_SIGNATURE,
         @version, # version of encoding software
         @fstype, # filesystem type
         Zip::ZipEntry::VERSION_NEEDED_TO_EXTRACT, # @versionNeededToExtract           ,
       ## LINE EDITED TO ACCOMMODATE UTF-8
         0b100000000000, # @gp_flags                  ,
       ##
         @compression_method,
         @time.to_binary_dos_time, # @lastModTime                      ,
         @time.to_binary_dos_date, # @lastModDate                      ,
         @crc,
         @compressed_size,
         @size,
         @name ? @name.bytesize : 0,
         @extra ? @extra.c_dir_length : 0,
         @comment ? comment.bytesize : 0,
         0, # disk number start
         @internalFileAttributes, # file type (binary=0, text=1)
         @externalFileAttributes, # native filesystem attributes
         @localHeaderOffset,
         @name,
         @extra,
         @comment].pack('VCCvvvvvVVVvvvvvVV')

    io << @name
    io << (@extra ? @extra.to_c_dir_bin : "")
    io << @comment
  end

  def calculate_local_header_size #:nodoc:all
    Zip::ZipEntry::LOCAL_ENTRY_STATIC_HEADER_LENGTH + (@name ? @name.bytesize : 0) + (@extra ? @extra.local_size : 0)
  end


  def cdir_header_size #:nodoc:all
    Zip::ZipEntry::CDIR_ENTRY_STATIC_HEADER_LENGTH + (@name ? @name.bytesize : 0) +
        (@extra ? @extra.c_dir_size : 0) + (@comment ? @comment.bytesize : 0)
  end
end
