class AndsPartyHarvester

  require 'net/http'
  require 'uri'
  require 'nokogiri'
  require 'time'
  require_relative 'oai'
  include OAI

  ANDS_NS = 'http://ands.org.au/standards/rif-cs/registryObjects'

  def initialize
    @party_keys = AndsParty.select("key").map(&:key)
  end

  def harvest(base_url, options={})
    from_date = options[:from_date]

    params = {
      :verb           => 'ListRecords',
      :metadataPrefix => 'rif',
      :set            => 'class:party'
    }
    if from_date
      params[:from] = from_date.utc.iso8601.to_s
    end

    fetch_options = { :params => params }
    fetch_options.merge(options)

    OAI::Harvester.fetch_and_process(base_url, fetch_options) do |doc|
      create_records(doc, options)
    end

  end

  def create_records(doc, options={})
    output_path   = options[:output_file_path]
    output_prefix = options[:output_file_prefix]
    save_output   = !(output_path.nil? or output_path.empty?)
    force         = options[:force] || false

    write_file(doc.to_xml, output_path, output_prefix) if save_output

    record_count = 0
    doc.xpath('//ands:registryObject', {'ands' => ANDS_NS}).each do |ro|
      group = ro['group']
      party_node = ro.at_xpath('./ands:party[@type="person"]', {'ands' => ANDS_NS})
      next if party_node == nil
      key_node = ro.at_xpath('./ands:key', {'ands' => ANDS_NS})
      next if key_node == nil

      next if !force and party_exists?(key_node.content)

      record = build_party(party_node, key_node.content, group)
      record_count += 1 unless record.nil?
    end
    record_count
  end

  private

  def party_exists?(key)
    @party_keys.include?(key.strip)
  end

  def build_party(party_node, key, group)
    
    email = party_node.at_xpath(
      './/ands:electronic[@type="email"]/ands:value', {'ands' => ANDS_NS})
    name_node = party_node.at_xpath('./ands:name', {'ands' => ANDS_NS})
    return nil if name_node.nil?

    given = name_node.at_xpath(
      './ands:namePart[@type="given"]', {'ands' => ANDS_NS})
    family = name_node.at_xpath(
      './ands:namePart[@type="family"]', {'ands' => ANDS_NS})
    title = name_node.at_xpath(
      './ands:namePart[@type="title"]', {'ands' => ANDS_NS})
    return nil if (given.nil? and family.nil?)

    AndsParty.where(:key => key).map {|p| p.delete}

    AndsParty.create(
      :key => key.strip,
      :email => email && email.content.strip,
      :given_name => given && given.content.strip,
      :family_name => family && family.content.strip,
      :title => title && title.content.strip,
      :group => group.strip
    )
  end

  def write_file(xml_string, output_path, output_prefix)
    @file_index ||= 1
    file_path = File.join(output_path, (output_prefix || "") + @file_index.to_s + ".xml")
    puts "Writing to #{file_path}"
    File.open(file_path, 'wb') do |f|
      f.write(xml_string)
    end
    @file_index += 1
  end

end
