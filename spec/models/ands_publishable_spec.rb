# encoding: utf-8
require 'spec_helper'

describe AndsPublishable do

  before :all do
    Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_300")
    Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_305")

  end

  describe "Associations" do
    it { should belong_to :project }
    it { should have_and_belong_to_many :ands_subjects }
    it { should have_and_belong_to_many :for_codes }
    it { should have_and_belong_to_many :seo_codes }
    it { should have_and_belong_to_many :ands_subjects }
    it { should have_many :ands_related_infos }
    it { should have_many :ands_related_objects }

  end

  describe "Validations" do
    it { should validate_presence_of :collection_name }
    it { should validate_presence_of :moderator_id }
    it { should validate_presence_of :collection_description }
    it { should validate_presence_of :address }
    it { should validate_presence_of :access_rights }
  end


  describe "Rif CS Generation Tests" do

    it "should create correct rif-cs with everything" do

      p = AndsPublishable.create(:collection_name => "Oxidative Degradation of Polyamide Reverse Osmosis Membranes",
                                 :collection_description => "The collection was obtained from a range of experiments investigating the influence of free chlorine on polyamide reverse osmosis membranes under accelerated ageing conditions. Sodium Hypochlorite was used as a source of free chlorine and ATR-FTIR has been used to characterize the changes in membrane surface chemistry",
                                 :access_rights => APP_CONFIG['access_rights_templates']['Template 1'],
                                 :moderator_id => Factory(:user).id,
                                 :address => "UNESCO Centre for Membrane Science and Technology\r\nSchool of Chemical Engineering\r\nUNSW Australia 2052"
      )
      p.has_temporal_coverage = true
      p.coverage_start_date = Date.parse("1 may 2008")
      p.coverage_end_date = Date.parse("1 may 2009")

      p.for_codes << Factory(:for_code, :code => "0904")
      p.for_codes << Factory(:for_code, :code => "090404")

      p.ands_subjects << Factory(:ands_subject, :keyword => "ATR-FTIR")
      p.ands_subjects << Factory(:ands_subject, :keyword => "reverse osmosis")
      p.ands_subjects << Factory(:ands_subject, :keyword => "polyamide")
      p.ands_subjects << Factory(:ands_subject, :keyword => "salt rejection")

      p.ands_related_objects.create(:handle => "http://nla.gov.au/nla.party-593921", :relation => "hasAssociationWith")
      p.ands_related_objects.create(:handle => "hdl:1959.4/004_128", :relation => "isPresentedBy")
      p.ands_related_objects.create(:handle => "hdl:1959.4/004_135", :relation => "hasAssociationWith")
      p.ands_related_objects.create(:handle => "hdl:1959.4/004_126", :relation => "isPresentedBy")
      p.ands_related_objects.create(:handle => "hdl:1959.4/004_133", :relation => "hasAssociationWithSupervisor", :description => "Supervisor")
      p.ands_related_objects.create(:handle => "hdl:1959.4/004_136", :relation => "hasAssociationWith")
      p.ands_related_objects.create(:handle => "hdl:1959.4/004_132", :relation => "isOwnedBy")

      p.ands_related_infos.create(:info_type => "doi", :identifier => "10.1016/j.memsci.2009.10.018", :title => "A. Antony, R. Fudianto, S. Cox, G. Leslie, Assessing the oxidative degradation of polyamide reverse osmosis membrane—Accelerated ageing with hypochlorite exposure, Journal of Membrane Science, Volume 347, Issues 1-2, 1 February 2010, Pages 159-164")

      p.save

      AndsHandle.assign_handle(p)

      require "builder"
      xml = Builder::XmlMarkup.new(:indent => 2)

      returned_xml = p.to_rif_cs(xml)

      returned_hash = Hash.from_xml(returned_xml)
      read_xml = File.open("test/data/rifcs.xml", "r").read
      expected_hash = Hash.from_xml(read_xml)
      returned_hash.should eq(expected_hash)
    end
  end

end
