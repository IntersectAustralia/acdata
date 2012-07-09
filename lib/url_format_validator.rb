#Ideas and help from https://gist.github.com/102138


class UrlFormatValidator < ActiveModel::EachValidator
  require 'uri/http'

  def validate_each(record, attribute, value)
    unless value.blank?
      configuration = {:on => :save, :schemes => %w(http https ftp)}
      configuration.update(options)
      allowed_schemes = [*configuration[:schemes]].map(&:to_s)
      begin
        uri = URI.parse(value)
        if !allowed_schemes.include?(uri.scheme)
          raise(URI::InvalidURIError)
        end

        if [:scheme, :host].any? { |i| uri.send(i).blank? }
          raise(URI::InvalidURIError)
        end

      rescue URI::InvalidURIError # => e
        record.errors[attribute] << (options[:message] || "is not recognised as a valid URL (Did you miss the http:// ?)")
      end
    end
  end

end
