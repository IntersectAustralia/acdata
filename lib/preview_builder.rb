class PreviewBuilder

  def self.filepath(path, format)
    ext = File.extname(path)
    filepart = File.basename(path, ext)
    
    File.join(File.dirname(path), ".#{filepart}_prev.#{format}")
  end

  def self.is_image?(filename)
    filename.downcase.match(/\.(gif|jpe?g|png|tiff?)$/).present?
  end

  def self.make_image_preview(file_with_path)
    require 'thumbnailer'

    size = APP_CONFIG['preview_size']
    out_format = APP_CONFIG['preview_format']
    thumb_bg = APP_CONFIG['thumbnail_background']

    components = File.split(file_with_path)
    path = components[0]
    file_with_ext = components[1]
    ext = File.extname(file_with_ext)
    file = File.basename(file_with_ext, ext)

    # Dodgy hacks to get around shortcomings of gd2 gem. I died a little inside
    cleanup = case ext.downcase
                when /^\.tiff?$/
                  tmp_ext = "jpg"
                  true
                else
                  tmp_ext = nil
                  false
              end

    tmp_file = nil
    if cleanup
      tmp_file = "#{path}/#{file}_thumbnail_temp.#{tmp_ext}"
      FileUtils.copy(file_with_path, tmp_file)
      file_with_path = tmp_file
    end

    begin
      Rails.logger.debug("thumbnailing #{file_with_path}")
      #output_file = "#{path}/#{file}_prev.#{out_format}"
      output_file = self.filepath(file_with_path, out_format)
      Rails.logger.debug("thumbnailing file: #{output_file}")
      if out_format.eql?("jpg")
        thumb = ThumbNailer.box_with_background(file_with_path, size, thumb_bg['r'], thumb_bg['g'], thumb_bg['b'])
      else
        thumb = ThumbNailer.box_calc_transparancy(file_with_path, size)
      end


      case out_format
        when "gif"
          ThumbNailer.export(output_file, thumb, :format => "gif")
          mime = "image/gif"
        when "png"
          ThumbNailer.export(output_file, thumb, :format => "png")
          mime = "image/png"
        else
          ThumbNailer.export(output_file, thumb, :format => "jpg")
          mime = "image/jpeg"
      end

      Rails.logger.debug("Thumbnail saved as #{output_file}")
    rescue
      ex = $!
      pp ex
      Rails.logger.debug("Thumbnail failed:")
      Rails.logger.debug "------------"
      Rails.logger.debug(ex)
      Rails.logger.debug "------------"
      return nil, nil
    ensure
      if cleanup
        FileUtils.rm_rf(tmp_file)
      end
    end
    [File.basename(output_file), mime]
  end

end

