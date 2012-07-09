class MemreHarvester

  require 'net/http'
  require 'uri'
  require 'nokogiri'

  def self.fetch_and_store_properties(url, refresh = false)
    properties = get_properties(url)

    if properties
      MembraneProperty.destroy_all if refresh
      properties.each do |property|
        attributes = get_property_attributes(url, property)
        next if attributes.empty?

        techniques = get_technique(url, property)
        next if techniques.blank?
        attributes['measurement_techniques'] = techniques
        add_or_update_technique(attributes)
      end
    end

  end

  def self.get_properties(url)
    uri = URI(url)
    params = {:function => "getMaterialInfo"}
    uri.query = URI.encode_www_form(params)
    properties = []
    Net::HTTP.start(uri.host) do |http|
      http.read_timeout = 120 #seconds
      begin
        http.request_get(uri.request_uri) do |resp|
          unless resp.is_a?(Net::HTTPOK)
            raise "Could not retrieve #{url} : #{resp.message} #{resp.code}"
          end
          resp.read_body do |segment|
            properties = segment.sub(/^property=/, "").sub(/^(.*)\n.*\n.*\n$/, '\1').split("|")

          end

        end
      ensure
      end
    end
    properties
  end

  def self.get_property_attributes(url, name)
    uri = URI(url)
    params = {:function => "getProperty", :param => name.gsub(/\s/, "_")}
    uri.query = URI.encode_www_form(params)
    attributes = {}
    Net::HTTP.start(uri.host) do |http|
      http.read_timeout = 120 #seconds
      begin
        http.request_get(uri.request_uri) do |resp|
          unless resp.is_a?(Net::HTTPOK)
            raise "Could not retrieve #{url} : #{resp.message} #{resp.code}"
          end
          resp.read_body do |response|
            raise "Property #{name} returned no result" if response =~ /no\sresult/
            hash_array = response.downcase.split(/=|\|/)
            return nil if hash_array.empty?
            hash_array << "" if hash_array.last.eql?("measurement")
            rejects = %w{image_name caption measurement}
            attributes = Hash[*hash_array].reject { |k, v| rejects.include?(k) }

          end

        end
        attributes["name"] = name
      ensure
      end
    end
    attributes
  end

  def self.get_technique(url, property)
    uri = URI(url)
    params = {:function => "getTechnique", :param => property.gsub(/\s/, "_")}
    uri.query = URI.encode_www_form(params)
    techniques = nil
    Net::HTTP.start(uri.host) do |http|
      http.read_timeout = 120 #seconds
      begin
        http.request_get(uri.request_uri) do |resp|
          unless resp.is_a?(Net::HTTPOK)
            raise "Could not retrieve #{url} : #{resp.message} #{resp.code}"
          end
          resp.read_body do |response|
            techniques = response.strip
          end
        end
      ensure
      end
    end
    techniques
  end

  private

  def self.add_or_update_technique(attributes)
    property = MembraneProperty.find_by_name(attributes["name"])

    if property
      property.update_attributes(attributes)
    else
      property = MembraneProperty.create!(attributes)
    end
  end

end
