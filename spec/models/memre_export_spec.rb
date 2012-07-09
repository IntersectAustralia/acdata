require 'spec_helper'

describe MemreExport do
  it { should belong_to :dataset }
  it { should have_and_belong_to_many :characterised_by }
  it { should have_many :property_details }
  it { should validate_presence_of :material_name }
  it { should validate_presence_of :material_class_name }
  it { should validate_presence_of :form_description }
  it {
    %w(Organic Inorganic Biological Hybrid).each do |val|
      should allow_value(val).for(:material_class_name)
    end
  }
  it {
    ['Flat Sheet', 'Hollow Fibre', 'Tubular', 'Other'].each do |val|
      should allow_value(val).for(:form_description)
    end
  }

  describe "XML generation" do

    it "should generate XML" do
      me = Factory(:memre_export, :material_name => "test",
                   :material_class_name => "Organic",
                   :creator => "UNSW",
                   :form_description => "Flat Sheet",
                   :name => "Processing Name",
                   :notes => "Processing Notes")

      me.characterised_by << AndsParty.create(:title => "",
                                              :given_name => "Ronald",
                                              :family_name => "McDonald",
                                              :group => "KFC",
                                              :key => "1")

      me.characterised_by << AndsParty.create(:title => "",
                                              :given_name => "Burger",
                                              :family_name => "King",
                                              :group => "Oportos",
                                              :key => "2")

      me.property_details << PropertyDetail.create(:name => "Contact Area",
                                                   :type_of_property => "Surface",
                                                   :property_units => "cm",
                                                   :measurement_technique => "Goniometer Method",
                                                   :info_type => "Book",
                                                   :identifier => "Some citation 1",
                                                   :notes => "google.com",
                                                   :description => "Property 1 description",
                                                   :qualifier_1 => "Property 1 qualifier 1",
                                                   :qualifier_2 => "Property 1 qualifier 2",
                                                   :qualifier_3 => "Property 1 qualifier 3")

      me.property_details << PropertyDetail.create(:name => "Diffusion Coefficient",
                                                   :type_of_property => "Volumetric",
                                                   :property_units => "m<sup>2</sup> s<sup>-1</sup>",
                                                   :measurement_technique => "Atomistic Simulation",
                                                   :info_type => "Book Chapter",
                                                   :identifier => "Some citation 2",
                                                   :notes => "yahoo.com",
                                                   :description => "Property 2 description",
                                                   :qualifier_1 => "Property 2 qualifier 1",
                                                   :qualifier_2 => "Property 2 qualifier 2",
                                                   :qualifier_3 => "Property 2 qualifier 3")

      require "builder"
      xml = Builder::XmlMarkup.new(:indent => 2)

      Time.stub(:now) { Time.new(2012, 06, 26, 13, 50) }

      returned_xml = me.to_xml(xml)

      returned_hash = Hash.from_xml(returned_xml)
      read_xml = File.open("test/data/membranes.xml", "r").read
      expected_hash = Hash.from_xml(read_xml)
      returned_hash.should eq(expected_hash)

    end
  end
end
