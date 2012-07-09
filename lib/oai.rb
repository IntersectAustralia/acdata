module OAI
  module Exception
    class BadArgument < StandardError
    end

    class BadResumptionToken < StandardError
    end

    class BadVerb < StandardError
    end

    class CannotDisseminateFormat < StandardError
    end

    class IdDoesNotExist < StandardError
    end

    class NoRecordsMatch < StandardError
    end

    class NoMetadataFormats < StandardError
    end

    class NoMetadataFormats < StandardError
    end
  end

  class Harvester

    require 'net/http'
    require 'uri'
    require 'nokogiri'
    require 'time'

    OAI_NS = 'http://www.openarchives.org/OAI/2.0/'

    def self.fetch_and_process(url, options={})

      uri = URI(url)
      resumption_token = nil

      begin
        if resumption_token.nil?
          params = options[:params]
        else
          params = {
            :verb            => options[:params][:verb],
            :resumptionToken => resumption_token
          }
        end

        uri.query = URI.encode_www_form(params)
        res = Net::HTTP.get_response(uri)

        unless res.is_a?(Net::HTTPSuccess)
          res.value
        end

        doc = Nokogiri::XML(res.body)
        if error_response?(doc)
          raise oai_exception(doc)
        end

        yield doc

        resumption_token = get_resumption_token(doc)
      end until resumption_token.nil?
    end

    private

    def self.error_response?(doc)
      !doc.at_xpath('//oai:error', {'oai' => OAI_NS}).nil?
    end

    def self.oai_exception(doc)
      error = doc.at_xpath('//oai:error', {'oai' => OAI_NS})
      code = error['code']
      OAI::Exception.const_get(code[0,1].capitalize + code[1..-1]).new(error.content)
    end

    def self.get_resumption_token(doc)
      resumption_token_node = doc.at_xpath('//oai:resumptionToken', {'oai' => OAI_NS})
      if !resumption_token_node.nil? and resumption_token_node.content.size > 0
        resumption_token_node.content
      else
        nil
      end
    end

  end
end
