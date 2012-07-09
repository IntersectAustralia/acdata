require 'spec_helper'

describe InstrumentFileType do

  class SomeParser
  end

  describe "Associations" do
    it { should have_and_belong_to_many(:instruments) }
  end

  describe "Parser for file type" do
    it "should return a parser instance if there is a parser name" do
      file_type = Factory(:instrument_file_type, :parser_name => 'SomeParser')
      parser = mock(SomeParser)
      SomeParser.stub(:new) { parser }
      file_type.parser.should == parser
    end

    it "should return no parser where no parser name is specified" do
    end
  end

  describe "File filtering" do
    let(:file_type) { Factory(:instrument_file_type, :filter => 'foo; bar') }
    it "should return true for files with extensions matching its filter" do
      file_type.file_filter_match('file.foo').should be_true
      file_type.file_filter_match('any_file.bar').should be_true
    end

    it "should return false for files with extensions not in the filter" do
      file_type.file_filter_match('file.baz').should be_false
    end
  end

  describe "Recognise known file types" do
    it "should recognise file types that have filters but not parsers" do
      file_type = Factory(:instrument_file_type, :filter => 'txt; text')
      file_type.parser.should be_nil
      file_type.recognise?('foo.txt').should be_true
      file_type.recognise?('foo.text').should be_true
      file_type.recognise?('foo.tx').should be_false
    end

    it "should recognise files types that have parsers only" do
      file_type = Factory(:instrument_file_type, :parser_name => 'SomeParser')
      file_type.file_filter_match('any_file').should be_true
      parser = mock(SomeParser)
      SomeParser.stub(:new) { parser }
      parser.should_receive(:recognise?).and_return(true)
      file_type.recognise?('foo.txt').should be_true
    end

    it "should recognise files with filters and parsers" do
      file_type = Factory(:instrument_file_type,
                          :parser_name => 'SomeParser',
                          :filter => 'foo; bar')
      parser = mock(SomeParser)
      SomeParser.stub(:new) { parser }
      parser.should_receive(:recognise?).and_return(true)
      file_type.recognise?('file.foo').should be_true
      parser.should_receive(:recognise?).and_return(true)
      file_type.recognise?('file.bar').should be_true

      file_type.recognise?('file.baz').should be_false
    end
  end

  describe "Identify file types" do
    it "should identify only those file types associated with the instrument" do
      file_type1 = Factory(:instrument_file_type, :filter => 'foo')
      file_type2 = Factory(:instrument_file_type, :filter => 'bar')
      file_type3 = Factory(:instrument_file_type, :filter => 'baz')
      instrument = Factory(:instrument,
                            :instrument_file_types => [file_type1, file_type2])
      InstrumentFileType.identify('file.foo', instrument).should == file_type1
      InstrumentFileType.identify('file.bar', instrument).should == file_type2
      InstrumentFileType.identify('file.baz', instrument).should be_nil
    end
  end

  describe "Missing dependencies" do
    it "should raise an error if a given parser class does not exist" do
      file_type = Factory(:instrument_file_type, :parser_name => 'NonParser')
      lambda {file_type.parser}.should raise_error(NameError)
    end
  end
end
