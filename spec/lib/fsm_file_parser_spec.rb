require 'spec_helper'

describe FsmFileParser do

  let(:parser) { FsmFileParser.new }

  describe "Special steps for fsm file" do
    it "should get the multiline value for polynomials" do
      content = <<EOC
Somekey: someval\r
Polynomials: \r
  A: abc\r
  B: def\r
Apodize Data: val
EOC
      expected = { "Polynomials" => { "value" => "A: abc\r\n  B: def\r\n", 'core' => false, 'supplied' => false } }
      metadata = parser.extract_metadata(StringIO.new(content))
      metadata.should == expected
    end
  end

end
