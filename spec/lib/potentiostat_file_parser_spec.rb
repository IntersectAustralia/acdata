require 'spec_helper'

describe PotentiostatFileParser do

  let(:parser) {
    PotentiostatFileParser.new()
  }

  describe "Potentiostat file parsing" do
    it "should map key names to their display names" do
      content = <<EOC
Time: someval\r
Exp  Conditions: someval\r
EOC
      metadata = parser.extract_metadata(StringIO.new(content))
      metadata.should include "Experiment Mode"
    end

    it "should raise exceptions on invalid source files" do
      file = mock(File)
      File.stub(:open).and_return(file)
      file.stub(:each).and_yield("Exp. Conditions: someval\r")
      metadata = { "Number of Data Points" => {'value' => "1"} }
      lambda {parser.valid?('/dummy/path', metadata)}.should raise_error
    end
  end

end
