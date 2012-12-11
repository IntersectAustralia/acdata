require 'spec_helper'

describe Instrument do

  let(:instrument1) {
    Factory(:instrument,
            :instrument_class => "NMR",
            :instrument_file_types => []
    )
  }
  let(:instrument2) {
    Factory(:instrument,
            :instrument_class => "Raman Spectrometers",
            :name => "Renishaw",
            :instrument_file_types => [
                Factory(:instrument_file_type, :name => 'File 1', :filter => '1'),
                Factory(:instrument_file_type, :name => 'File 2', :filter => '2')
            ]
    )
  }
  let(:instrument3) {
    Factory(:instrument,
            :instrument_class => "Raman Spectrometers",
            :name => "Renishaw",
            :instrument_file_types => [
                Factory(:instrument_file_type, :name => 'File 1', :filter => '1'),
                Factory(:instrument_file_type, :name => 'File 2')
            ]
    )
  }

  describe "Associations" do
    it { should have_many(:datasets) }
    it { should have_and_belong_to_many(:instrument_file_types) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:instrument_class) }

    before :each do
      Factory(:instrument, :name => "Name", :instrument_class => "Class Name")
    end

    it "should prevent duplicate instrument names" do
      instrument = Instrument.new(:name => "Name", :instrument_class => "Class 1")
      instrument.should_not be_valid
      instrument.should have(1).error_on(:name)
    end

    it "should prevent duplicate names with leading and trailing whitespace" do
      instrument = Instrument.new(:name => "  Name  ", :instrument_class => "Class 1")
      instrument.should_not be_valid
      instrument.should have(1).error_on(:name)
    end

    it "should prevent duplicate names with leading whitespace" do
      instrument = Instrument.new(:name => "  Name", :instrument_class => "Class 1")
      instrument.should_not be_valid
      instrument.should have(1).error_on(:name)
    end

    it "should prevent duplicate names with trailing whitespace" do
      instrument = Instrument.new(:name => "Name  ", :instrument_class => "Class 1")
      instrument.should_not be_valid
      instrument.should have(1).error_on(:name)
    end

  end

  describe "Get extension filter" do
    it "should return nil if no filters are specified" do
      instrument1.file_filter.should be_nil
    end
    it "should return a semicolon separated list of filters if specified" do
      instrument2.file_filter.should eq('1; 2')
    end
    it "should return a nil if any of the file types have a nil filter" do
      instrument3.file_filter.should be_nil
    end
  end

  describe "Default ordering of returned instruments" do
    it "should be ordered by instrument class then by name" do
      instrument_1 = Factory(:instrument, :name => 'Beta', :instrument_class => 'Sad')
      instrument_2 = Factory(:instrument, :name => 'Alpha', :instrument_class => 'Happy')
      instrument_3 = Factory(:instrument, :name => 'Omega', :instrument_class => 'Happy')
      instrument_4 = Factory(:instrument, :name => 'Omega 3', :instrument_class => 'Glad')
      Instrument.all.should eq([instrument_4, instrument_2, instrument_3, instrument_1])
    end
  end

  describe "Publishing of instruments" do
    it "should export correctly" do
      instrument = Factory(:instrument, :name => 'Renishaw Raman RM100', :instrument_class => 'Sad')
      Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_325")
      Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_325")
      AndsHandle.assign_handle(instrument)

      instrument.update_attributes(:email => "a.rich@unsw.edu.au",
                                   :voice => "+61 (2) 9385 9795",
                                   :description => "The RM1000 uses a microscope to focus a 780nm laser onto a sample and " +
                                       "the scattered light passes through a Raman spectrometer. The 50x microscope objective on the 1000RM " +
                                       "enables the 780nm laser spot to be focused to a smaller spot than is possible with the 785nm laser on " +
                                       "the RamanStation. We recommend the RM1000 when you need to measure features smaller than 100micron on the sample surface\r\n\n" +
                                       "Excitation source: 780nm (infrared) laser.\r\nMicroscope objectives available: 5x, 10x, and 50x, plus 20x long working distance.\r\n" +
                                       "Manual stage only (mapping not available).\r\nSamples include organic compounds and polymers with chromophores exhibiting fluorescence.",
                                   :address => "Room G31\r\n" +
                                       "Chemical Sciences Bldg F10\r\n" +
                                       "University of NSW\r\n" +
                                       "Kensington NSW 2052",
                                   :managed_by => "Mark Wainright Analytical Centre")

      instrument.publish

      sanitized_handle = instrument.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
      file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
      File.exists?(file_path).should eq(true)
      returned_xml = File.open(file_path, "r").read
      returned_hash = Hash.from_xml(returned_xml)
      read_xml = File.open("test/data/test_service_record.xml", "r").read
      expected_hash = Hash.from_xml(read_xml)
      returned_hash.should eq(expected_hash)


    end
    it "should exclude email if not defined" do
      instrument = Factory(:instrument, :name => 'Renishaw Raman RM100', :instrument_class => 'Sad')
      Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_325")
      Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_325")
      AndsHandle.assign_handle(instrument)

      instrument.update_attributes(:email => "",
                                   :voice => "+61 (2) 9385 9795",
                                   :description => "The RM1000 uses a microscope to focus a 780nm laser onto a sample and " +
                                       "the scattered light passes through a Raman spectrometer. The 50x microscope objective on the 1000RM " +
                                       "enables the 780nm laser spot to be focused to a smaller spot than is possible with the 785nm laser on " +
                                       "the RamanStation. We recommend the RM1000 when you need to measure features smaller than 100micron on the sample surface\r\n\n" +
                                       "Excitation source: 780nm (infrared) laser.\r\nMicroscope objectives available: 5x, 10x, and 50x, plus 20x long working distance.\r\n" +
                                       "Manual stage only (mapping not available).\r\nSamples include organic compounds and polymers with chromophores exhibiting fluorescence.",
                                   :address => "Room G31\r\n" +
                                       "Chemical Sciences Bldg F10\r\n" +
                                       "University of NSW\r\n" +
                                       "Kensington NSW 2052",
                                   :managed_by => "Mark Wainright Analytical Centre")

      instrument.publish

      sanitized_handle = instrument.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
      file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
      File.exists?(file_path).should eq(true)
      returned_xml = File.open(file_path, "r").read
      returned_hash = Hash.from_xml(returned_xml)
      read_xml = File.open("test/data/test_service_record_without_email.xml", "r").read
      expected_hash = Hash.from_xml(read_xml)
      returned_hash.should eq(expected_hash)

    end

    it "should exclude address if both not defined" do
      instrument = Factory(:instrument, :name => 'Renishaw Raman RM100', :instrument_class => 'Sad')
      Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_325")
      Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_325")
      AndsHandle.assign_handle(instrument)

      instrument.update_attributes(:email => "a.rich@unsw.edu.au",
                                   :voice => "",
                                   :description => "The RM1000 uses a microscope to focus a 780nm laser onto a sample and " +
                                       "the scattered light passes through a Raman spectrometer. The 50x microscope objective on the 1000RM " +
                                       "enables the 780nm laser spot to be focused to a smaller spot than is possible with the 785nm laser on " +
                                       "the RamanStation. We recommend the RM1000 when you need to measure features smaller than 100micron on the sample surface\r\n\n" +
                                       "Excitation source: 780nm (infrared) laser.\r\nMicroscope objectives available: 5x, 10x, and 50x, plus 20x long working distance.\r\n" +
                                       "Manual stage only (mapping not available).\r\nSamples include organic compounds and polymers with chromophores exhibiting fluorescence.",
                                   :address => "",
                                   :managed_by => "Mark Wainright Analytical Centre")

      instrument.publish

      sanitized_handle = instrument.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
      file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
      File.exists?(file_path).should eq(true)
      returned_xml = File.open(file_path, "r").read
      returned_hash = Hash.from_xml(returned_xml)
      read_xml = File.open("test/data/test_service_record_without_address.xml", "r").read
      expected_hash = Hash.from_xml(read_xml)
      returned_hash.should eq(expected_hash)


    end
    it "should export correctly" do
      instrument = Factory(:instrument, :name => 'Renishaw Raman RM100', :instrument_class => 'Sad')
      Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_325")
      Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_325")
      AndsHandle.assign_handle(instrument)

      instrument.update_attributes(:email => "a.rich@unsw.edu.au",
                                   :voice => "",
                                   :description => "The RM1000 uses a microscope to focus a 780nm laser onto a sample and " +
                                       "the scattered light passes through a Raman spectrometer. The 50x microscope objective on the 1000RM " +
                                       "enables the 780nm laser spot to be focused to a smaller spot than is possible with the 785nm laser on " +
                                       "the RamanStation. We recommend the RM1000 when you need to measure features smaller than 100micron on the sample surface\r\n\n" +
                                       "Excitation source: 780nm (infrared) laser.\r\nMicroscope objectives available: 5x, 10x, and 50x, plus 20x long working distance.\r\n" +
                                       "Manual stage only (mapping not available).\r\nSamples include organic compounds and polymers with chromophores exhibiting fluorescence.",
                                   :address => "Room G31\r\n" +
                                       "Chemical Sciences Bldg F10\r\n" +
                                       "University of NSW\r\n" +
                                       "Kensington NSW 2052",
                                   :managed_by => "Mark Wainright Analytical Centre")

      instrument.publish

      sanitized_handle = instrument.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
      file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
      File.exists?(file_path).should eq(true)
      returned_xml = File.open(file_path, "r").read
      returned_hash = Hash.from_xml(returned_xml)
      read_xml = File.open("test/data/test_service_record_without_number.xml", "r").read
      expected_hash = Hash.from_xml(read_xml)
      returned_hash.should eq(expected_hash)


    end

  end

end
