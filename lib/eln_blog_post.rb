class ELNBlogPost
  include ProjectZip
  include Rails.application.routes.url_helpers
  Rails.application.routes.default_url_options = ActionMailer::Base.default_url_options

  require 'time'
  require 'net/http'
  require 'uri'
  require 'nokogiri'
  require 'base64'

  def initialize(url='https://www.enotebook.science.unsw.edu.au', uid)
    @uid = uid
    @base_url = url
  end

  def add_data(filename, file_path)
    post_url = "#{@base_url}/api/rest/adddata/uid/#{@uid}"
    ext = File.extname(filename)
    if ext
      ext = ext[1..-1]
    end
    file = File.open(file_path)
    encoded_file = Base64.strict_encode64(file.read)
    file.close
    post_body = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.dataset_ {
        xml.title_ self.class.clean_filename(filename)
        xml.data_ {
          xml.dataitem_(encoded_file, :type => 'inline', :main => '1', :ext => ext, :filename => self.class.clean_filename(filename))
        }
      }
    end
    Rails.logger.debug("ELNBlogPost.add_data post_body=#{post_body.to_xml(:indent => 4)}")
    xml = parse_response(send_request(post_url, post_body.to_xml(:indent => 4)))
    data_id = xml.at_xpath('//data_id').content
  end

  def add_files(attachments)
    file_ids = []
    file_links = []
    attachments.each do |attachment|
      # http://en.wikipedia.org/wiki/Base64#Padding
      # works out to be ~1.4
      att_size = attachment.file_size * APP_CONFIG['encoding_padding']
      if att_size > Settings.instance.file_size_limit.megabytes
        file_links << "Download #{attachment.filename} (larger than #{Settings.instance.file_size_limit}MB) at #{download_attachment_url(attachment)}"
      else
        if attachment.format == 'folder'
          file = generate_zip(attachment.path, attachment.filename)
          file_ids << add_data(attachment.filename + ".zip", file)
        else
          file_ids << add_data(attachment.filename, attachment.path)
        end
      end
    end
    return file_ids, file_links
  end

  def post(username, blog, title, section, content, timestamp, metadata, data_ids, data_links, post_url=nil, reason=nil)
    action = post_url.nil? ? 'addpost' : 'editpost'

    action_url = "#{@base_url}/api/rest/#{action}/uid/#{@uid}"

    post_body = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.post {
        if post_url and post_url.match(Regexp.new(blog + '/(\d+)'))
          xml.id_ Regexp.last_match.captures.first
        end
        xml.title_ self.class.sanitise(title)
        xml.section_ self.class.sanitise(section)
        xml.author_ {
          xml.username_ username
        }
        xml.content_ {
          merged_content = content
          data_links.each do |link|
            merged_content += "\n"
            merged_content += link
          end
          xml.cdata self.class.sanitise(merged_content)
        }
        xml.datestamp_ timestamp.iso8601
        xml.blog_sname_ blog
        xml.metadata_ {
          metadata.each do |key, value|
            xml.send(self.class.normalise(key).to_sym, self.class.sanitise(value, true))
          end
        }
        xml.attached_data_ {
          data_ids.each do |id|
            xml.data_ id, :type => 'local'
          end
        }
        if reason
          xml.edit_reason_ reason
        end
      }
    end

    Rails.logger.debug("ELNBlogPost.post (#{action}) post_body=#{post_body}")
    xml = parse_response(send_request(action_url, post_body.to_xml(:indent => 4)))
    post_url_xml = xml.at_xpath('//post_info')
    post_url = nil
    if post_url_xml
      post_url = post_url_xml.content.gsub(/\.xml$/, '')
      Rails.logger.debug("ELNBlogPost.post post_url=#{post_url}")
    end
    post_url
  end

  #
  # The Labtrove web application silently fails when creating key names that
  # contain certain characters. It looks like the key names they accept are
  # ones that would be valid XML tag names, since they're used as such.
  #
  def self.normalise(key)
    key.gsub(/^[^A-Za-z]/, '_').gsub(/[^A-Za-z0-9_]/, '_').downcase
  end

  #
  # Labtrove doesn't escape it's content properly when rendering it in XML
  # (i.e they should probably wrap the content in CDATA tags).
  # We'll do some sanitising here, but we won't cover everything.
  #
  def self.sanitise(value, full=false)
    svalue = value.gsub(/\&/, 'and')
    svalue.gsub!(/[\<\>]/, '_') if full
    svalue
  end

  def self.clean_filename(value)
    svalue = self.sanitise(value, true)
    svalue.gsub(/"/, '')
  end

  private

  def send_request(url, post_body)
    uri = URI.parse(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    # You shouldn't do this. TODO: refer to ca-certs
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"request" => post_body})

    response = http.request(request)
  end

  def parse_response(resp)
    Rails.logger.debug("ELN Blog post response code: #{resp.code}")
    content = resp.body
    if content.empty?
      raise "ELN server error: #{resp.message}"
    end
    Rails.logger.debug("ELN Blog post response: #{resp.body}")
    xml = Nokogiri::XML(content)
    outcome = xml.at_xpath('//result/success').content
    Rails.logger.debug("ELN Blog post response: success = #{outcome}")
    unless outcome == 'true'
      raise xml.at_xpath('//reason').content
    end

    xml
  end

end
