require 'spec_helper'

describe AndsPartyHarvester do

  let(:base_url) { 'http://example.com' }

  let(:party_records){
    IO.read('spec/resources/party_records.xml')
  }

  let(:party_harvester){ AndsPartyHarvester.new }

  describe "Retrieval" do
    it "should retrieve party records" do
      records_url = "#{base_url}?verb=ListRecords&metadataPrefix=rif&set=class:party"
      stub_request(:get, records_url)
        .to_return(:body => party_records, :status => ['200', 'OK'])
      party_harvester.harvest(base_url)
    end

    it "should retrieve party records from a given date" do
      from_date = Time.now
      records_url = "#{base_url}?verb=ListRecords&metadataPrefix=rif&set=class:party&from=#{from_date.utc.iso8601}"
      stub_request(:get, records_url)
        .to_return(:body => party_records, :status => ['200', 'OK'])
      party_harvester.harvest(base_url, {:from_date => from_date})
    end
  end

  describe "Storing records" do
    before :each do
      fetch_and_store
    end

    it "should add persons" do
      AndsParty.all.count.should == 15

      party1 = AndsParty.find_by_key('MON:0000123711')
      party1.given_name.should == 'Oded'
      party1.family_name.should == 'Kleifeld'
      party1.title.should == 'Dr'
      party1.email.should == 'Oded.Kleifeld@monash.edu'
      party1.group.should == 'Monash University'
    end

    it "should not add persons without a name" do
      AndsParty.find_by_key('piccloud.arcs.org.au.maintainer.Hideki_Miura').should be_nil
    end

    it "should only add records with party type of person" do
      AndsParty.find_by_key('piccloud.arcs.org.au.maintainer.D.C._Franklin').should be_nil
    end

    it "should replace records when forced" do
      party1 = AndsParty.find_by_key('MON:0000123711')
      orig_id = party1.id

      fetch_and_store
      party_harvester.harvest(base_url, {:force => true})
      party1 = AndsParty.find_by_key('MON:0000123711')
      party1.id.should_not == orig_id
    end

    def fetch_and_store
      records_url = "#{base_url}?verb=ListRecords&metadataPrefix=rif&set=class:party"
      stub_request(:get, records_url)
        .to_return(:body => party_records, :status => ['200', 'OK'])
      party_harvester.harvest(base_url)
    end
  end
end
