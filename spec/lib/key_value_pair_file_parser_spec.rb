require 'spec_helper'

describe KeyValuePairFileParser do

  let(:parser) {
    KeyValuePairFileParser.new(
        ["Laser Power", "Exposure Time"],
        ["Another tag"],
        [],
        {"Laser Power" => "Evil Laser"})
  }
  let(:expected) {
    {
        "Evil Laser" => {"value" => "100%", "core" => true, "supplied" => false},
        "Another tag" => {"value" => "blah", "core" => false, "supplied" => false}
    }
  }

  describe "Metadata extraction" do
    it "should parse a given file for metadata" do
      file = mock(File)
      File.should_receive(:open).and_return(file)
      parser.should_receive(:extract_metadata).with(file)
      attachment = Factory(:attachment)
      parser.parse(attachment)
    end

    it "should extract values and indicate whether they are core" do
      content = <<EOC
Somekey: someval\r
Laser Power: 100%\r
Another tag = blah\r
EOC
      metadata = parser.extract_metadata(StringIO.new(content))
      metadata.should == expected
    end
  end

end
