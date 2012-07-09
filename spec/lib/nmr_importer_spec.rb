require 'spec_helper'
require 'rake'

describe "NMRImporter" do

  describe "importing" do
    before :each do
      @nmr_file_type = Factory(:instrument_file_type,
                              :name => 'NMR',
                              :parser_name => 'NmrFolderParser')
      @i1 = Factory(:instrument,
                    :instrument_class => 'NMR',
                    :name => 'ccc (Gyro)',
                    :instrument_file_types => [@nmr_file_type])
      @u1 = Factory(:user, :status => 'A', :nmr_username => 'aaa')
      FileUtils.cp_r FileList["spec/resources/nmr_backup/*"], "spec/resources/"

      Instrument.should_receive(:find).with(102).and_return(@i1)
      User.should_receive(:find).with(50).and_return(@u1)
    end

    after :each do
      File.exists?("spec/resources/nmr/102").should be_false
      project = Project.where(:name => 'NMR Server Data', :user => @u1).first
      FileUtils.rm_rf(project.project_path)
      FileUtils.rm_rf("spec/resources/nmr")
    end

    it "should create the default project and import the samples to it" do
      Project.where(:name => 'NMR Server Data', :user => @u1).first.should be_nil
      NMRImporter.import('spec/resources/nmr')
      project = Project.where(:name => 'NMR Server Data', :user => @u1).first
      project.should_not be_nil
      import_samples_tests(project)
    end

    it "should import samples to the NMR Server Data project" do
      NMRImporter.import('spec/resources/nmr')
      project = Project.where(:name => 'NMR Server Data', :user => @u1).first
      import_samples_tests(project)
    end

    it "should not import samples that already exist" do
      project = Project.create!(:name => 'NMR Server Data', :user => @u1)
      project.samples.create!(:name => '120213-cdb')
      NMRImporter.import('spec/resources/nmr')
      project.samples.where(:name => '120213-cdb').size.should == 1
      sample = project.samples.where(:name => '120213-cdb').first
      sample.datasets.should be_empty
    end

    it "should import samples that already exist if forced" do
      project = Project.create!(:name => 'NMR Server Data', :user => @u1)
      project.samples.create!(:name => '120213-cdb')
      NMRImporter.import('spec/resources/nmr', false)

      project.samples.where(:name => '120213-cdb').size.should == 2
    end

    def import_samples_tests(project)
      project.samples.map(&:name).should =~ %w{120213-cdb 120214-cdb}
      sample1 = project.samples.find_by_name('120213-cdb')
      sample2 = project.samples.find_by_name('120214-cdb')
      dataset1 = sample1.datasets.first
      dataset1.should_not be_nil
      dataset1.name.should == 'Supervisor Harper Bmim Br - 1'
      dataset1.attachments.size.should == 1
      attachment = dataset1.attachments.first
      attachment.instrument_file_type.should == @nmr_file_type
    end
  end

  describe "extracting title from NMR folder" do

    before :all do
      FileUtils.cp_r FileList["spec/resources/nmr_backup/*"], "spec/resources/"
    end

    after :all do
      FileUtils.rm_rf("spec/resources/nmr")
    end

    it "should get give the value from the title file" do
      NMRImporter.extract_title('spec/resources/nmr/102/50/120213-cdb/1').should == 'Supervisor Harper Bmim Br - 1'
    end

    it "should return Untitled where there is no title file" do
      NMRImporter.extract_title('/foo/bar').should == 'Untitled - bar'
    end

    it "should return Untitled where there is no title file content" do
      NMRImporter.extract_title('spec/resources/nmr_titleless').should == 'Untitled - nmr_titleless'
    end
  end
end
