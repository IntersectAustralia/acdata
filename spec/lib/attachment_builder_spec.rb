require 'spec_helper'

describe AttachmentBuilder do

  class FileTypeAParser
    def recognise?(file_path)
      file_path.match(/\.a$/)
    end
    def parse(attachment)
      {}
    end
  end

  let(:file_type_a) {
    Factory(:instrument_file_type, :name => 'A', :filter => 'a', :parser_name => 'FileTypeAParser')
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
            ]
    )
  }
  let(:file1) {
    File.new(Rails.root.join("test/data", 'file.a'))
  }
  let(:file2) {
    File.new(Rails.root.join("test/data", 'file.b'))
  }
  let(:file3) {
    File.new(Rails.root.join("test/data", 'file.c'))
  }

  let(:files_root) {
    Rails.root.join('tmp')
  }

  describe "Building attachments" do

    class TestDatasetRules
      def self.verify(candidates, dataset)
        case dataset.name
        when "Good"
          {
            :verified => candidates,
            :rejected => []
          }
        when "Bad"
          {
            :verified => [],
            :rejected => candidates.map{|c| [c, "testing rejection"]}
          }
        when "Some Bad"
          {
            :verified => [candidates[0]],
            :rejected => candidates[1..-1].map{|c| [c, "testing rejection"]}
          }
        end
      end
    end

    it "should add attachments to a dataset" do
      sample = Factory(:sample)
      dataset = Dataset.create(:name => "Good", :sample => sample, :instrument => instrument1)
      params = {
        :dirStruct => '[{"file_1":"file.a"}]',
        :destDir => "1275/1197",
        :file_1 => file1
      }
      ab = AttachmentBuilder.new(params, files_root, TestDatasetRules)
      ab.should_receive(:indelible?).and_return(false)
      ab.should_receive(:metadata_source?).and_return(false)
      ab.should_receive(:visualisable?).and_return(false)
      result = ab.build(dataset, ActiveSupport::JSON.decode(params[:dirStruct]))
      result.include?("file.a").should be_true
      result["file.a"][:status].should == "success"

      attachment = dataset.attachments.first
      attachment.should_not be_nil
      attachment.filename.should == "file.a"
      attachment.instrument_file_type.should eq(file_type_a)
    end

    it "should not create attachments when rules verification fails" do
      sample = Factory(:sample)
      dataset = Dataset.create(:name => "Bad", :sample => sample, :instrument => instrument1)
      params = {
        :dirStruct => '[{"file_1":"file.a"}]',
        :destDir => "1275/1197",
        :file_1 => file1
      }
      ab = AttachmentBuilder.new(params, files_root, TestDatasetRules)
      result = ab.build(dataset, ActiveSupport::JSON.decode(params[:dirStruct]))
      result.include?("file.a").should be_true
      result["file.a"][:status].should == "failure"

      dataset.attachments.should be_empty
    end

    it "should handle both success and failure when handling multiple files" do
      sample = Factory(:sample)
      dataset = Dataset.create(:name => "Some Bad", :sample => sample, :instrument => instrument1)
      params = {
        :dirStruct => '[{"file_1":"file.a"},{"file_2":"file.b"},{"file_3":"file.c"}]',
        :destDir => "1275/1197",
        :file_1 => file1,
        :file_2 => file2,
        :file_3 => file3
      }
      ab = AttachmentBuilder.new(params, files_root, TestDatasetRules)
      ab.should_receive(:indelible?).and_return(false)
      ab.should_receive(:metadata_source?).and_return(false)
      ab.should_receive(:visualisable?).and_return(false)
      result = ab.build(dataset, ActiveSupport::JSON.decode(params[:dirStruct]))

      result.include?("file.a").should be_true
      result["file.a"][:status].should == "success"

      %w{file.b file.c}.each do |f|
        result.include?(f).should be_true
        result[f][:status].should == "failure"
      end

      dataset.attachments.size.should == 1
      attachment = dataset.attachments.first
      attachment.should_not be_nil
      attachment.filename.should == "file.a"
      attachment.instrument_file_type.should eq(file_type_a)
    end

    after(:each) do 
      Project.all.each do |p|
        filename = File.join(files_root, "project_#{p.id}")
        FileUtils.rm_rf(filename) if File.exists?(filename)
      end
    end

  end

end
