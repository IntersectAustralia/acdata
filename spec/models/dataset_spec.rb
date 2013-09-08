require 'spec_helper'

describe Dataset do

  let(:file_type_a) {
    Factory(:instrument_file_type, :name => 'A', :filter => 'a')
  }
  let(:file_type_b) {
    Factory(:instrument_file_type, :name => 'B', :filter => 'b')
  }
  let(:file_type_c) {
    Factory(:instrument_file_type, :name => 'C', :filter => 'c')
  }
  let(:file_type_d) {
    Factory(:instrument_file_type, :name => 'D', :filter => 'd')
  }
  let(:instrument_rule) {
    Factory(:instrument_rule,
            :metadata_list => "A",
            :indelible_list => "D",
            :unique_list => "A,B,C",
            :exclusive_list => "B,C"
    )
  }
  let(:instrument1) {
    Factory(:instrument,
            :instrument_class => "Sprocket Maker",
            :name => "Spacely",
            :instrument_file_types => [
                file_type_a, file_type_b, file_type_c
            ],
            :instrument_rule => instrument_rule
    )
  }

  describe "Associations" do
    it { should belong_to :sample }
    it { should belong_to :instrument }
    it { should have_many :metadata_values }
    it { should have_many :attachments }
  end

  describe "Validations" do

    before :each do
      file_type_a.should_not be_nil
      @sample = Factory(:sample)
      @dataset = Dataset.create(:name => "Name", :sample => @sample, :instrument => instrument1)
    end

    it { should validate_presence_of(:sample) }
    it { should validate_presence_of(:name) }

    it "should not allow duplicate record names" do
      dataset1 = Dataset.create(:name => "Name", :sample => @sample, :instrument => instrument1)
      dataset1.should_not be_valid
    end

    it "should find duplicates even with leading whitespace" do
      dataset1 = Dataset.create(:name => "    Name", :sample => @sample, :instrument => instrument1)
      dataset1.should_not be_valid
    end

    it "should find duplicates even with trailing whitespace" do
      dataset1 = Dataset.create(:name => "Name   ", :sample => @sample, :instrument => instrument1)
      dataset1.should_not be_valid
    end

  end

  describe "attachment rules" do
    pending
  end

  describe "Before hooks" do
    it "should remove the dataset files when the dataset is destroyed" do
      dataset = Factory(:dataset)
      dataset.should_receive(:delete_files)
      dataset.destroy
    end
  end

  describe "Whitespace stripper" do
    it "should remove leading whitespace from the dataset name" do
      dataset = Factory(:dataset, :name => "   Hola")
      dataset.name.should eq("Hola")
    end

    it "should remove trailing whitespace from the dataset name" do
      dataset = Factory(:dataset, :name => "Hola   ")
      dataset.name.should eq("Hola")
    end

    it "should remove leading and trailing whitespace from the dataset name" do
      dataset = Factory(:dataset, :name => "   Hola   ")
      dataset.name.should eq("Hola")
    end
  end

  describe "Handling metadata" do
    it "should return a list of metadata instrument file types" do
      dataset = Dataset.create(:name => "Name", :sample => @sample, :instrument => instrument1)
      dataset.instrument_rule.metadata_file_type_names.should == ['A']
    end

    it "should indicate whether it has metadata values or not" do
      dataset = Factory(:dataset)
      dataset.metadata?.should be_false
      dataset.add_metadata("foo", "bar")
      dataset.metadata?.should be_true
    end

    it "should delete the metadata associated with a given attachment" do
      dataset = Factory(:dataset)
      att = dataset.attachments.create!()
      dataset.add_metadata('key1', 'value1', {:attachment => att})
      MetadataValue.find_by_key('key1').should_not be_nil
      MetadataValue.find_by_key('key1').attachment.should eql(att)
      dataset.delete_metadata(att)
      MetadataValue.find_by_key('key1').should be_nil
    end

    it "should delete metadata when the supplying attachment is destroyed" do
      dataset = Factory(:dataset)
      att = dataset.attachments.create!()
      dataset.add_metadata('key1', 'value1', {:attachment => att})
      MetadataValue.find_by_key('key1').should_not be_nil
      att.destroy
      MetadataValue.find_by_key('key1').should be_nil
    end

    it "should flag metadata as core and/or suppled when given" do
      dataset = Factory(:dataset)
      dataset.add_metadata('key1', 'value1', {:core => true})
      dataset.add_metadata('key2', 'value2')
      dataset.add_metadata('key3', 'value3', {:supplied => true})
      dataset.add_metadata('key4', 'value4', {:core => true, :supplied => true})
      MetadataValue.find_by_key('key1').core?.should be_true
      MetadataValue.find_by_key('key1').supplied?.should be_false
      MetadataValue.find_by_key('key2').core?.should be_false
      MetadataValue.find_by_key('key2').supplied?.should be_false
      MetadataValue.find_by_key('key3').core?.should be_false
      MetadataValue.find_by_key('key3').supplied?.should be_true
      MetadataValue.find_by_key('key4').core?.should be_true
      MetadataValue.find_by_key('key4').supplied?.should be_true
    end

    it "should record the attachment the metadata belongs to" do
      dataset = Factory(:dataset)
      att = dataset.attachments.create!()
      dataset.add_metadata('key1', 'value1')
      dataset.add_metadata('key2', 'value2', {:attachment => att})
      MetadataValue.find_by_key('key1').attachment.should be_nil
      MetadataValue.find_by_key('key2').attachment.should eql(att)
    end
  end

  describe "Output for the API" do
    it "should return a basic object representing the dataset" do
      dataset = Factory(:dataset, :name => "Dataset A")
      dataset.summary_for_api.should eq(dataset.name)
    end
  end

  describe "Moving datasets between samples" do
    it "should not update sample parent if move is unsuccessful" do
      sample1 = Factory(:sample)
      sample2 = Factory(:sample)
      dataset = Factory(:dataset, :sample => sample1)

      FileUtils.mkdir_p(dataset.dataset_path)
      FileUtils.stub(:mv).and_return { raise StandardError }

      Dataset.transaction do
        src = dataset.dataset_path
        dataset.update_attributes(:sample => sample2)
        lambda { Dataset.move_dataset(dataset, src) }.should raise(ActiveRecord::Rollback)
        dataset.errors[:base].should include("There was an error in moving the dataset. Please contact an administrator")

      end

      Dataset.find(dataset.id).sample.should eq(sample1)
    end

    it "should update sample parent if dataset has no files" do
      sample1 = Factory(:sample)
      sample2 = Factory(:sample)
      dataset = Factory(:dataset, :sample => sample1)

      FileUtils.stub(:mv).and_return { raise StandardError }

      Dataset.transaction do
        src = dataset.dataset_path
        dataset.update_attributes(:sample => sample2)
        lambda { Dataset.move_dataset(dataset, src) }.should raise_error
      end

    end

  end

=begin
  describe "Zipping a folder" do
    before :each do
      @sample = Factory(:sample, :name => "s1", :batchId => "123")
      @file_to_cleanup = nil
      @path_to_cleanup = nil
    end

    after :each do
      File.delete(@file_to_cleanup)
      FileUtils.rm_rf(@path_to_cleanup)
    end

    it "should return a correct zipped file for a simple directory with 2 files" do
      dataset = Factory(:dataset, :attachment_file_name => "testdir", :sample => @sample)
      FileUtils.mkdir_p(dataset.attachment.path)
      real_data_path = dataset.attachment.path[0..dataset.attachment.path.rindex("/")]
      @path_to_cleanup = real_data_path
      FileUtils.cp_r("test/data/testdir", real_data_path)

      file = dataset.generate_zip
      @file_to_cleanup = file
      zipfile = Zip::ZipFile.open(file.path)
      zipfile.find_entry("testdir/file1.txt").should_not eq(nil)
      zipfile.find_entry("testdir/file2").should_not eq(nil)
    end

    it "should return a correct zipped file for a deeply nested directory" do
      dataset = Factory(:dataset, :attachment_file_name => "deeplynesteddir", :sample => @sample)
      FileUtils.mkdir_p(dataset.attachment.path)
      real_data_path = dataset.attachment.path[0..dataset.attachment.path.rindex("/")]
      @path_to_cleanup = real_data_path
      FileUtils.cp_r("test/data/deeplynesteddir", real_data_path)

      file = dataset.generate_zip
      @file_to_cleanup = file
      zipfile = Zip::ZipFile.open(file.path)
      zipfile.find_entry("deeplynesteddir/dir1/file1.txt").should_not eq(nil)
      zipfile.find_entry("deeplynesteddir/dir1/file2.txt").should_not eq(nil)
      zipfile.find_entry("deeplynesteddir/dir1/dir1_1/myfile.txt").should_not eq(nil)
      zipfile.find_entry("deeplynesteddir/dir1/dir1_1/dir1_1_1/file3.txt").should_not eq(nil)
      zipfile.find_entry("deeplynesteddir/dir2/dir2_1/myfile.txt").should_not eq(nil)
    end

  end
=end

end
