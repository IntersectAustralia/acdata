String.class_eval do
  def to_filename
    self.strip.gsub(/[\x00-\x1F\[\]\/\\<>\|:\*"\?\^\n]/,'_') #get rid of illegal characters
  end

  def to_ascii
    self.encode("ISO-8859-1", :undef => :replace, :replace => '_')
  end
end

