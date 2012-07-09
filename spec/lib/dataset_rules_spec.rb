require 'spec_helper'

describe DatasetRules do

  let(:file_type_a) {
    Factory(:instrument_file_type, :name => 'A', :filter => 'a', :parser_name => 'FileTypeAParser')
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
  let(:file_type_e) {
    Factory(:instrument_file_type, :name => 'E', :filter => 'e')
  }
  let(:file_type_f) {
    Factory(:instrument_file_type, :name => 'F', :filter => 'f')
  }
  let(:instrument_rule) {
    Factory(:instrument_rule,
            :metadata_list => "A",
            :indelible_list => "D",
            :unique_list => "B",
            :exclusive_list => "B,C",
            :visualisation_list => "E,F"
    )
  }
  let(:instrument1) {
    Factory(:instrument,
            :instrument_class => "Sprocket Maker",
            :name => "Spacely",
            :instrument_file_types => [
              file_type_a, file_type_b, file_type_c, file_type_d, file_type_e
            ],
            :instrument_rule => instrument_rule
    )
  }

  def unique_tests(file_type, ext, message=nil)
    dataset = Factory(:dataset, :instrument => instrument1)
    dataset.attachments.create!(:filename => "file.#{ext}", :instrument_file_type => file_type)
    filename = "file1.#{ext}"
    list = [
      {
        :filename => filename,
        :path => "/dummy/#{filename}",
        :format => 'file',
        :instrument_file_type => file_type
      },
    ]
    result = DatasetRules.verify(list, dataset)
    result[:verified].should be_empty
    result[:rejected][0].should == [list[0], message || "A file of type '#{ext.upcase}' already exists in the dataset."]
  end

  it "should reject attachments with the same filename" do
    dataset = Factory(:dataset)
    dataset.attachments.create!(:filename => "file.a")
    list = [
      {
        :filename => 'file.a',
        :path => '/dummy/file.a',
        :format => 'file',
      }
    ]
    result = DatasetRules.verify(list, dataset)
    result[:verified].should be_empty
    result[:rejected].first.should eq([list[0], "This file already exists."])
  end

  describe "Reject attachments not meeting the uniqueness rules" do
    it "should reject more than one file type from the unique list" do
      unique_tests(file_type_b, 'b')
    end

    it "should reject more than one of the same metadata file type" do
      unique_tests(file_type_a, 'a')
    end

    it "should reject more than one of the same visualisable file type" do
      unique_tests(file_type_e, 'e', "A visualisation file already exists.")
    end
  end

  describe "Reject attachments not meeting the exclusiveness rules" do
    it "should not accept 2 or more files from the exclusive file type list" do
      # There can only be one of either B or C instrument file types
      dataset = Factory(:dataset, :instrument => instrument1)
      # A file in the xor list
      dataset.attachments.create!(:filename => "file.b", :instrument_file_type => file_type_b)
      list = [
        {
          :filename => 'file.c',
          :path => '/dummy/file.c',
          :format => 'file',
          :instrument_file_type => file_type_c
        }
      ]
      result = DatasetRules.verify(list, dataset)
      result[:verified].should be_empty
      result[:rejected].count.should == 1
      result[:rejected][0].should == [list[0], "A similar file type already exists in the dataset."]
    end

    it "should reject other visualisable file types where there are multiple" do
      dataset = Factory(:dataset, :instrument => instrument1)
      # A file in the visualisation list
      dataset.attachments.create!(:filename => "file.e", :instrument_file_type => file_type_e)
      list = [
        {
          :filename => 'file.f',
          :path => '/dummy/file.f',
          :format => 'file',
          :instrument_file_type => file_type_f
        }
      ]
      result = DatasetRules.verify(list, dataset)
      result[:verified].should be_empty
      result[:rejected].count.should == 1
      result[:rejected][0].should == [list[0], "A visualisation file already exists."]
    end
  end

end
