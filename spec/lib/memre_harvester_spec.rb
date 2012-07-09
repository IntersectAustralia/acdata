require 'spec_helper'

describe MemreHarvester do
  let(:base_url){'http://membranes.edu.au/valet/ajax.cgi'}
  let(:base_url){'http://example.com'}
  let(:get_props_body){'property=one|two|three'}
  let(:get_attrs_body){'image_name=MemReLogo.JPG|caption=test|Description=examples of membranes|Property_Type=Volumetric|Property_Units=m<sup>2</sup>|Qualifier1=q1|Qualifier2=q2|Qualifier3=q3|measurement='}
  let(:get_tech_body){'Bubble Point Method|Permeability Method|Scanning Electron Microscopy'}
  let(:attr_hash) {
    {
      "description"=>"examples of membranes",
      "property_type"=>"volumetric",
      "property_units"=>"m<sup>2</sup>",
      "qualifier1"=>"q1",
      "qualifier2"=>"q2",
      "qualifier3"=>"q3",
      "name"=>"test property"
    }
  }
  let(:mp_hash) {
    {
      "description"=>"examples of membranes",
      "property_type"=>"volumetric",
      "property_units"=>"m<sup>2</sup>",
      "qualifier1"=>"q1",
      "qualifier2"=>"q2",
      "qualifier3"=>"q3",
      "name"=>"test property",
      "measurement_techniques" => get_tech_body
    }
  }

  it "should return the list of membrane properties" do
    stub_request(:get, "#{base_url}/?function=getMaterialInfo").
      to_return(:status => 200, :body => get_props_body, :headers => {})
 
    MemreHarvester.get_properties(base_url).should == %w{one two three}
  end

  it "should return the list of attributes for a given membrane property" do
    WebMock.enable!
    stub_request(:get, "#{base_url}/?function=getProperty&param=test_property").
      to_return(:status => 200, :body => get_attrs_body, :headers => {})

    MemreHarvester.get_property_attributes(base_url, 'test property').
      should == attr_hash
  end

  it "should return a list of techniques for a given property" do
    stub_request(:get, "#{base_url}/?function=getTechnique&param=test_property").
      to_return(:status => 200, :body => get_tech_body, :headers => {})

    MemreHarvester.get_technique(base_url, 'test property').should == get_tech_body
  end

  describe "Add Membrane Property" do
    before :each do
      MembraneProperty.find_by_name(mp_hash['name']).should be_nil
      MemreHarvester.add_or_update_technique(mp_hash)
    end

    it "should add a membrane property record if none exists" do
      MembraneProperty.find_by_name(mp_hash['name']).should_not be_nil
    end

    it "should update a membrane property record if one already exists" do
      mp_orig = MembraneProperty.find_by_name(mp_hash['name'])
      attr_update = mp_hash.clone
      attr_update['property_type'] = Time.now.to_s
      MemreHarvester.add_or_update_technique(attr_update)
      mp_updated = MembraneProperty.find_by_name(mp_hash['name'])
      mp_orig.id.should == mp_updated.id
      mp_orig.property_type.should_not == mp_updated.property_type
    end
  end

  describe "Fetch and store properties" do
    before :each do
      MemreHarvester.stub(:get_properties).with(base_url).and_return(['one'])
      MemreHarvester.stub(:get_property_attributes).with(base_url,'one').and_return(attr_hash)
      MemreHarvester.stub(:get_technique).with(base_url, 'one').and_return(get_tech_body)
    end

    it "should add properties" do
      MemreHarvester.fetch_and_store_properties(base_url, false)
      MembraneProperty.find_by_name(mp_hash['name']).should_not be_nil
    end

    it "should update properties" do
      attr_orig = mp_hash.clone
      orig_property_type = Time.now.to_s
      attr_orig['property_type'] = orig_property_type
      MemreHarvester.add_or_update_technique(attr_orig)
      mp_orig = MembraneProperty.find_by_name(attr_orig['name'])
      MemreHarvester.fetch_and_store_properties(base_url, false)
      mp_updated = MembraneProperty.find_by_name(attr_orig['name'])
      mp_orig.property_type.should_not == mp_updated.property_type
    end

    it "should replace properties" do
      MemreHarvester.add_or_update_technique(mp_hash)
      mp_orig = MembraneProperty.find_by_name(mp_hash['name'])
      MemreHarvester.fetch_and_store_properties(base_url, true)
      mp_updated = MembraneProperty.find_by_name(mp_hash['name'])
      mp_orig.name.should == mp_updated.name
      mp_orig.id.should_not == mp_updated.id
    end

  end
end
__END__
