require 'gd2-ffij'
require 'exifr'


# Thumbnailer originally written by Peter Hickman (2008..ish? I think?)
# http://rubygems.org/gems/thumbnailer
#
# parts rewritten by Intersect Australia Limited, (C) 2011
# www.intersect.org.au

# Scales the given image to fit within a box of the required
# size with either a transparent background or one specified
# by the user. Should the source image be a JPEG with the 
# image orientation set in the EXIF data then the thumbnail
# will be rotated to the correct orientation.
#
# The return value is the thumbnail data in +png+ format. Both the
# default colour and the output type can be changed.
#
# Performance is sufficient that this can be used to generate
# thumbnails on the fly.
#
# Example using the defaults:
#
#  f = File.new('happytree_t.png', 'w')
#  f.puts ThumbNailer.box_with_transparancy('happytree.jpg', 125)
#  f.close
#
# Example changing the defaults:
#
#  ThumbNailer.colours(1.0, 0.5, 0.1)
#  ThumbNailer.output_gif
#
#  f = File.new('happytree_t.gif', 'w')
#  f.puts ThumbNailer.box_with_background('happytree.jpg', 125)
#  f.close
#
# The colours used for the background or transparancy can be set
# on a per call basis:
#
#  f = File.new('happytree_t.gif', 'w')
#  f.puts ThumbNailer.box_with_background('happytree.jpg', 125, 0.8, 0.2, 0.7)
#  f.close
#
# Whatever colour is used for transparancy there is always a chance that
# it is used in a picture and that the resulting thumbnail will look like
# Swiss Cheese. The alternative is to use the box_calc_transparancy method
# which will search the image for an unused colour to use for the transparancy
# colour. As this is extra work over and above that done by box_with_transparancy
# the method is a little slower. However the search is conducted over the scaled
# image and not the original source so if your thumbnails are small (125 pixels
# or less) then you can still use this method on the fly.
#
# A few extra function that I have found useful have been added to the 
# package just so everything is in one place.
#
#  f = File.new('happytree_t.gif', 'w')
#  f.puts ThumbNailer.max_width('happytree.jpg', 125)
#  f.close
#
# This will scale the image so that it is no wider than +size+ whilest
# maintaining the aspect ratio. There is also max_height to scale the
# image so that it is no taller than +size+ and max_either to scale the 
# image if either width or height is larger than +size+.

class ThumbNailer
  VERSION = '1.4.0'

  # The default colour, an impure black to be used for
  # transparency or background
  @@r = 0.0
  @@g = 0.0
  @@b = 10.0 / 255.0

  # Given the filename of an image and the required size
  # of the thumbnail this will scale and center the image 
  # to fit within the box against a transparent background.
  #
  # If the image is smaller than the box then it will be
  # centered within the box as is.
  def self.box_with_transparancy(source, size, r = @@r, g = @@g, b = @@b)
    image = GD2::Image.import(source)

    dstX, dstY, dstW, dstH, image = resize_source(image, size)

    thumbnail = GD2::Image.new(size, size)
    thumbnail.transparent = GD2::Color[r, g, b, GD2::ALPHA_TRANSPARENT]
    thumbnail.draw do |canvas|
	    canvas.color = GD2::Color[r, g, b]
	    canvas.point(1,1)
	    canvas.fill()
	  end
	  thumbnail.copy_from(image,dstX,dstY,0,0,dstW,dstH)

	  return create_output(thumbnail, source)
  end

  # Like box_with_transparancy this method scales the image within
  # a box of +size+ width and height. This method searhes the image
  # for an unused color and selects that for transparency. If no
  # unused colour is found then it uses the default or given colour.
  # 
  # Given that it must find all the colours that are used in an image
  # to find just one unused colour this is much slower than the plain
  # box_with_transparancy. However the search for an unused colour is
  # conducted against the scaled image so it will not necessarily be
  # as bad as you might imagine.
  def self.box_calc_transparancy(source, size, r = @@r, g = @@g, b = @@b)
    image = GD2::Image.import(source)

    dstX, dstY, dstW, dstH, image = resize_source(image, size)

    r, g, b = find_unused_color(image, r, g, b)

    thumbnail = GD2::Image.new(size, size)
    thumbnail.transparent = GD2::Color[r, g, b, GD2::ALPHA_TRANSPARENT]
    thumbnail.draw do |canvas|
	    canvas.color = GD2::Color[r, g, b]
	    canvas.point(1,1)
	    canvas.fill()
	  end
	  thumbnail.copy_from(image,dstX,dstY,0,0,dstW,dstH)

	  return create_output(thumbnail, source)
  end

  # Given the filename of an image and the required size
  # of the thumbnail this will scale and center the image 
  # to fit within the box against the background colour.
  #
  # If the image is smaller than the box then it will be
  # centered within the box as is.
  def self.box_with_background(source, size, r = @@r, g = @@g, b = @@b)
    image = GD2::Image.import(source)

    dstX, dstY, dstW, dstH, image = resize_source(image, size)

    thumbnail = GD2::Image.new(size, size)
    thumbnail.draw do |canvas|
	    canvas.color = GD2::Color[r, g, b]
	    canvas.point(1,1)
	    canvas.fill()
	  end
	  thumbnail.copy_from(image,dstX,dstY,0,0,dstW,dstH)

	  return create_output(thumbnail, source)
  end

  # Scale the source image so that it is no wider than +size+
  # or return the image as is if it is already +size+ or smaller
  def self.max_width(source, size)
    image = GD2::Image.import(source)
    
    if image.width > size
      scale = size.to_f / image.width.to_f
      new_width = image.width.to_f * scale
      new_height = image.height.to_f * scale
      
      image.resize!(new_width, new_height, true)
    else
      # do nothing, return as is
    end

    return create_output(image, source)
  end
  
  # Scale the source image so that it is no higher than +size+
  # or return the image as is if it is already +size+ or smaller
  def self.max_height(source, size)
    image = GD2::Image.import(source)
    
    if image.height > size
      scale = size.to_f / image.height.to_f
      new_width = image.width.to_f * scale
      new_height = image.height.to_f * scale
      
      image.resize!(new_width, new_height, true)
    else
      # do nothing, return as is
    end

    return create_output(image, source)
  end
  
  # Scale the source image so that it is no wider or higher than 
  # +size+ or return the image as is if it is already +size+ or smaller
  def self.max_either(source, size)
    image = GD2::Image.import(source)

    max = image.width > image.height ? image.width : image.height
  
    if max > size
      scale = size.to_f / max.to_f
      new_width = image.width.to_f * scale
      new_height = image.height.to_f * scale

      image.resize!(new_width, new_height, true)
    else
      # do nothing, return as is
    end

    return create_output(image, source)
  end

  # Change the defaults that will be used to set the 
  # background or transparency unless they are overridden
  # in a call to box_with_background or box_with_transparancy
  def self.colours(r, g, b)
    @@r = r.to_f
    @@g = g.to_f
    @@b = b.to_f
  end

  def self.export(output_file, image, options = {})
     image.export(output_file, options)
  end


  private

  def self.create_output(image, source)
    correct_orientation(image, source)
  end

  def self.offset(a, b, size)
    x = ( size - ( ( a / b ) * size ) ) / 2.0
    return x
  end

  def self.resize_source(image, size)
    # Save us from having to put to_f on the end all the time
    iw = image.width.to_f
    ih = image.height.to_f
    is = size.to_f

    dstX = 0
    dstY = 0
    dstW = 0
    dstH = 0

  	if iw < is and ih < is
  		# Image is smaller than the box
  		dstX = (is - iw) / 2.0
  		dstY = (is - ih) / 2.0
  		dstW = iw
  		dstH = ih
  	else
  		# Image is bigger than the box
  		max = 0

  		if iw > ih
  		  max = iw
  		  dstY = offset( ih, iw, is )
  		else
  		  max = ih
  		  dstX = offset( iw, ih, is )
  		end

  		dstW = ( iw / max ) * is
  		dstH = ( ih / max ) * is

  		image.resize!(dstW, dstH, true)
  	end
  	
  	return dstX, dstY, dstW, dstH, image
  end

  def self.correct_orientation(image, source)
	  orientation = 0

  	begin
		  info = EXIFR::JPEG.new(source)
		  orientation = info.orientation.to_i
	  rescue Exception => e
		  # Either not a jpg or has no EXIF data
	  end

	  case orientation
	  when 2
		  # ) transform="-flip horizontal";; 
	  when 3
		  image.rotate!(degrees_to_rad(-180.0), image.width.to_f / 2.0, image.height.to_f / 2.0)
	  when 4
		  # ) transform="-flip vertical";; 
	  when 5
		  # ) transform="-transpose";; 
	  when 6
		  image.rotate!(degrees_to_rad(-90.0), image.width.to_f / 2.0, image.height.to_f / 2.0)
	  when 7
		  # ) transform="-transverse";; 
	  when 8
		  image.rotate!(degrees_to_rad(-270.0), image.width.to_f / 2.0, image.height.to_f / 2.0)
	  else
		  # No rotation required
	  end

	  return image
  end

  def self.degrees_to_rad(degrees)
	  return (degrees * (Math::PI / 180.0))
  end
  
  # Convert the rgb into an integer
  def self.rgb_to_i(r, g, b)
  	return (r * 65536) + (g * 256) + b
  end

  # Convert an integer into rgb
  def self.i_to_rgb(i)
  	b = i % 256
  	i -= b
  	i /= 256
  	g = i % 256
  	i -= g
  	i /= 256
  	r = i

  	return r,g,b
  end
  
  def self.find_unused_color(image, r, g, b)
    x = Array.new(256*256*256,0)

    image.each do |row|
    	row.each do |pixel|
    		rgb = image.pixel2color(pixel)
    		x[rgb_to_i(rgb.r, rgb.g, rgb.b)] += 1
    	end
    end

    y = x.index(0)
    if y != nil
      return i_to_rgb(y)
    else
      return r, g, b
    end
  end
end
