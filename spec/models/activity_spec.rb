require 'spec_helper'

describe Activity do

  describe "Validations" do
    it { should validate_presence_of :project_name }
    it { should validate_presence_of :funding_sponsor }
    it { should validate_numericality_of :initial_year }

    it "should validate RDA grant ID exists if from RDA" do
      activity = Activity.new(:project_id => 1, :project_name => "Name", :funding_sponsor => "Class 1", :from_rda => true)
      activity.should_not be_valid
      activity.should have(1).error_on(:rda_grant_id)
    end

    it "should not validate RDA handle exists if not from RDA" do
      activity = Activity.new(:project_id => 1, :project_name => "Name", :funding_sponsor => "Class 1", :from_rda => false)
      activity.should be_valid
    end

    it "should validate published is marked as true if from RDA" do
      activity = Activity.new(:project_id => 1, :project_name => "Name", :funding_sponsor => "Class 1", :from_rda => true, :rda_grant_id => 1)
      activity.should_not be_valid
      activity.should have(1).error_on(:published)
      activity.published = true
      activity.should be_valid


    end
  end

  describe "Rif CS Generation Tests" do

    it "should create correct rif-cs with if it's a new activity record'" do

      activity = Factory(:activity, :from_rda => false,
                         :project_name => "Project Name",
                         :initial_year => "2003",
                         :duration => "3 years",
                         :total_grant_budget => "$1,000,000",
                         :funding_sponsor => "The Government",
                         :funding_scheme => "Some scheme")
      Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_325")
      Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_325")

      AndsHandle.assign_handle(activity)

      activity.for_codes << Factory(:for_code, :code => "0904")
      activity.for_codes << Factory(:for_code, :code => "090404")

      activity.save

      activity.publish

      sanitized_handle = activity.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
      file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
      File.exists?(file_path).should eq(true)
      returned_xml = File.open(file_path, "r").read
      returned_hash = Hash.from_xml(returned_xml)
      read_xml = File.open("test/data/test_activity_record.xml", "r").read
      expected_hash = Hash.from_xml(read_xml)
      returned_hash.should eq(expected_hash)
    end

    it "should not create rif-cs with if it's from RDA" do

      rda_grant = Factory(:rda_grant, :key => "http://esrc.unimelb.edu.au/OHRM#N000291", :grant_id => "N000291")
      activity = Factory(:activity, :from_rda => true, :rda_grant => rda_grant, :published => true)
      AndsHandle.assign_handle(activity).should eq("http://esrc.unimelb.edu.au/OHRM#N000291")
      activity.publish

      sanitized_handle = activity.handle.gsub(/[^0-9A-Za-z.\-]/, '_')
      file_path = "#{APP_CONFIG['rda_files_root']}/#{Time.now.strftime("%Y%m%d")}/#{sanitized_handle}.xml"
      File.exists?(file_path).should eq(false)
    end
  end
  describe "ands handle test" do

    it "should return the correct handle" do

      activity = Factory(:activity, :from_rda => false,
                         :project_name => "Project Name",
                         :initial_year => "2003",
                         :duration => "3 years",
                         :total_grant_budget => "$1,000,000",
                         :funding_sponsor => "The Government",
                         :funding_scheme => "Some scheme")
      Settings.instance.update_attribute(:start_handle_range, "hdl:1959.4/004_325")
      Settings.instance.update_attribute(:end_handle_range, "hdl:1959.4/004_325")
      AndsHandle.assign_handle(activity)

      activity.for_codes << Factory(:for_code, :code => "0904")
      activity.for_codes << Factory(:for_code, :code => "090404")

      activity.save

      activity.handle.should eq("hdl:1959.4/004_325")

      activity.update_attributes(:rda_grant => Factory(:rda_grant, :key => "http://purl.org/au-research/grants/arc/FF0348307", :grant_id => "FF0348307"), :from_rda => true)

      activity.handle.should eq("http://purl.org/au-research/grants/arc/FF0348307")


    end


  end
end
