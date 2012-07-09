require 'spec_helper'

describe Attachment do

  describe "Associations" do
    it { should belong_to :dataset }
  end

  describe "Validations" do
    it { should validate_presence_of(:dataset) }

    it "should allow attachments without a preview file or preview mime type" do
      Factory(:attachment).should be_valid
    end

    it "should allow attachments with both a preview file and preview mime type" do
      Factory(:attachment, :preview_file => "/path/to/file.jpg", :preview_mime_type => "image/jpeg").should be_valid
    end

    it "should not allow attachments with only a preview file (missing preview mime type)" do
      a1 = Attachment.new(:preview_file => "/path/to/file.jpg")
      a1.should_not be_valid
    end

    it "should allow attachments with only a preview mime type (missing preview file)" do
      Factory(:attachment, :preview_mime_type => "image/jpeg").should be_valid
    end
  end

  describe "is of format method" do
    it "should return true if format matches" do
      Factory(:attachment, :format => "SP").is_of_format?("SP").should be_true
    end
    it "should return false for other formats" do
      Factory(:attachment, :format => "SPS").is_of_format?("SP").should be_false
    end
  end

  describe "scopes" do
    let(:file_type_a) {
      Factory(:instrument_file_type, :name => 'A', :filter => 'a')
    }
    let(:file_type_b) {
      Factory(:instrument_file_type, :name => 'B', :filter => 'b')
    }
    let(:file_type_c) {
      Factory(:instrument_file_type, :name => 'C', :filter => 'c')
    }
    let(:instrument1) {
      Factory(:instrument,
              :instrument_class => "Sprocket Maker",
              :name => "Spacely",
              :instrument_file_types => [
                file_type_a, file_type_b, file_type_c
              ],
              :indelible_list => "A",
              :unique_list => "A,B,C",
              :exclusive_list => "B,C"
      )
    }

    it "can filter attachments by instrument file type" do
      dataset = Factory(:dataset)
      att_a = dataset.attachments.create!(:instrument_file_type => file_type_a)
      att_b = dataset.attachments.create!(:instrument_file_type => file_type_b)
      att_c = dataset.attachments.create!(:instrument_file_type => file_type_c)

      dataset.attachments.filter_by([file_type_a.name]).count.should == 1
      dataset.attachments.filter_by([file_type_a.name]).first.should == att_a

      dataset.attachments.inverse_filter_by([file_type_a.name]).count.should == 2
      dataset.attachments.inverse_filter_by([file_type_a.name]).to_a.should == [att_b, att_c]
    end

  end

end
