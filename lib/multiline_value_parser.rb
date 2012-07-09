class MultilineValueParser

  def self.get_multiline_value(iostream, regex)
    contents = iostream.read
    contents.match(regex) {|m| return m.captures.first}
  end

end
