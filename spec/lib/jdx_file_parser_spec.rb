require 'spec_helper'

describe JDXFileParser do

  let(:core_tags) {
    {
      'singleline' => 'Single Line',
      'multiline'  => 'Multiline (3)'
    }
  }

  let(:supplied_tags) {
    {
    }
  }

  let(:extended_tags) {
    {
      'another single line' => 'Another Something',
      'another multi' => 'Group of Somethings'
    }
  }

  let(:expected) {
    {
      "Single Line" => { "value" => "some value", "core" => true },
      "Multiline (3)" => { "value" => "Alpha\r\nBravo\r\nCharlie", "core"=>true},
      "Another Something" => {"value" => "0.01", "core" => false},
      "Group of Somethings" => {"value" => "APODIZATION=STRONG\r\nDETECTOR=MIR TGS", "core" => false}
    }
  }

  let(:parser) {
    JDXFileParser.new(core_tags, extended_tags, supplied_tags)
  }

  describe "Parsing" do
    it "should parse file contents and return a metadata hash" do
      file = mock(File)
      File.should_receive(:open).and_return(file)
      parser.should_receive(:extract_metadata).with(core_tags.keys, extended_tags.keys, file)
      metadata = parser.parse('/dummy/path')
    end

    it "should extract the metadata values from a given set of keys" do
      content_stream = StringIO.new(
        "##singleline= some value\n" <<
        "##multiline= Alpha\r\nBravo\r\nCharlie\n" <<
        "##another single line= 0.01\n" <<
        "##another multi= APODIZATION=STRONG\r\nDETECTOR=MIR TGS"
      )
      metadata = parser.extract_metadata(core_tags.keys, extended_tags.keys, content_stream)
      metadata.should eq(expected)
    end
  end

  describe "Getting the JCAMP-DX version" do
    it "should return the JCAMP-DX version of JCAMP-DX files < version 6" do
      file = mock(File)
      File.should_receive(:open).and_yield(file)
      file.should_receive(:read).and_return("##JCAMP-DX= 3.14")
      JDXFileParser.version('/dummy/path').should == '3.14'
    end

    it "should return the JCAMP-DX version of JCAMP-DX files of version 6" do
      file = mock(File)
      File.should_receive(:open).and_yield(file)
      file.should_receive(:read).and_return("##JCAMPDX= 6.0")
      JDXFileParser.version('/dummy/path').should == '6.0'
    end
  end

end
