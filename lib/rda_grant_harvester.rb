class RdaGrantHarvester

  require 'net/http'
  require 'uri'
  require 'nokogiri'
  require_relative 'oai'
  include OAI

  ANDS_NS = 'http://ands.org.au/standards/rif-cs/registryObjects'

  def initialize(groups=['Australian Research Council', 'National Health and Medical Research Council'])
    @grant_keys = RdaGrant.select("key").map(&:key)
    @groups = groups
  end

  def harvest(base_url, options)
    from_date = options[:from_date]

    @groups.each do |group|
      params = {
        :verb           => 'ListRecords',
        :metadataPrefix => 'rif',
        :set            => ['class:activity', "group:#{URI.escape(group)}"]
      }
      if from_date
        params[:from] = from_date.utc.iso8601.to_s
      end

      fetch_options = { :params => params }
      fetch_options.merge(options)

      OAI::Harvester.fetch_and_process(base_url, fetch_options) do |doc|
        create_grant_records(doc, options)
      end
    end

  end

  def create_grant_records(doc, force=false)
    doc.xpath('//ands:registryObject', {'ands' => ANDS_NS}).each do |ro|
      group = ro['group']
      #check if activity type matters
      grant_node = ro.at_xpath('./ands:activity', {'ands' => ANDS_NS})
      next if grant_node == nil
      key_node = ro.at_xpath('./ands:key', {'ands' => ANDS_NS})
      next if key_node == nil

      next if !force and grant_exists?(key_node.content)

      grant = add_grant(grant_node, key_node.content, group)
    end
  end

  private

  def grant_exists?(key)
    @grant_keys.include?(key.strip)
  end

  def add_grant(grant_node, key, group)
    primary_name = grant_node.at_xpath('./ands:name[@type="primary"]/ands:namePart', {'ands' => ANDS_NS})
    return nil if primary_name.nil?

    alternative_name = grant_node.at_xpath('./ands:name[@type="alternative"]/ands:namePart', {'ands' => ANDS_NS})

    description = grant_node.at_xpath('./ands:description[@type="notes"]', {'ands' => ANDS_NS})
    grant_id = key[/\w+$/]

    return nil if (group.nil? and key.nil?)

    RdaGrant.where(:key => key).map {|p| p.delete}

    rda_grant = RdaGrant.create(
        :key => key.strip,
        :grant_id => grant_id,
        :primary_name => primary_name && primary_name.content.strip,
        :alternative_name => alternative_name && alternative_name.content.strip,
        :description => description && description.content.strip,
        :group => group.strip
    )
  end

end
