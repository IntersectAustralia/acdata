require 'net/telnet'
require 'erb'
require 'nokogiri'
require 'ostruct'
require 'singleton'

# We are using telnet to talk to the Aperio server because
# their server implementation does not follow the HTTP RFC
# and are case sensitive in the HTTP headers.
# Unfortunately Ruby's Net:HTTP does downcase all headers
# so both systems are not compatible.
#
# The templates for the requests can be found under
# lib/aperio/templates
#

class AperioClient

  def self.get_instance
    if APP_CONFIG['aperio_mock']
      aperio_mock
    else
      AperioClient.new
    end
  end

  def initialize
    @aperio_host = Net::Telnet::new("Host" => APP_CONFIG['aperio']['dataserver']['url'],
                                    "Port" => APP_CONFIG['aperio']['dataserver']['port'],
                                    "Prompt" => /</,
                                    "Telnetmode" => false)
    log_in
  end

  def update_project(project_id, data = {})
    update_project_params = {:token => @token, :id => project_id, :data => data}
    response = image_command("PutRecordData", update_project_params)
    throw Exception.new("Could not update Aperio record.\n #{response}") if response.xpath("//Id").text == ""
  end

  def create_project(data = {})
    get_project_params = {:token => @token, :data => escape_params(data)}
    response = image_command("PutRecordData", get_project_params)
    throw Exception.new("Could not create Aperio record.\n #{response}") if response.xpath("//Id").text == ""
  end

  def close
    @aperio_host.close
  end

  private

  def log_in
    login_params = {:user_name => APP_CONFIG['aperio']['username'], :password => APP_CONFIG['aperio']['password']}
    login_response = security_command("Logon", login_params)
    @token = login_response.xpath("//Token").text
    throw Exception.new("Could not log into Aperio dataserver.\n #{login_response}") if @token == ""
  end

  def image_command(method, params)
    send_aperio_request(method, 'Images/Image', params)
  end

  def security_command(method, params)
    send_aperio_request(method, 'Security/Security2', params)
  end

  def get_template_for(filename)
    ERB.new(IO.readlines("lib/aperio/templates/#{filename}.erb").join(""))
  end

  def evaluate_template(template, params_hash)
    parameters = OpenStruct.new(params_hash)
    get_template_for(template).result(parameters.instance_eval {binding} ).strip
  end

  def soap_request(method_name, params)
    soap_method_call = {:method_body => evaluate_template(method_name, params)}
    evaluate_template("http_body", soap_method_call)
  end

  def http_request(method_name, server_url, params)
    soap_body = soap_request(method_name, params)

    soap_body_params = {
      :soap_body => soap_body,
      :method_name => method_name,
      :server_url => server_url,
      :server => APP_CONFIG['aperio']['dataserver']['url'],
      :port => APP_CONFIG['aperio']['dataserver']['port'],
      :content_length => soap_body.length
    }
    Rails.logger.info evaluate_template("http_request", soap_body_params)
    evaluate_template("http_request", soap_body_params)
  end

  def send_aperio_request(method, server_url, params)
    response = @aperio_host.cmd(http_request(method, server_url, params))
    Nokogiri::XML(response.each_line.select { |line| line =~ /^</ }.join("") ).remove_namespaces!
  end

  #escape xml characters and newlines
  def escape_params(params)
    require 'builder'
    params.each { |k, v| params[k] = v.to_s.to_xs.gsub(/\r\n?/, "&#xA;") }
    params

  end

  private
  def self.aperio_mock
    mock = Object.new
    def mock.create_project(*args)
      true
    end
    def mock.close
      true
    end
    mock
  end

end
