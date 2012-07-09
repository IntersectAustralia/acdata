require 'spec_helper'

describe SpFileParser do

  let(:parser) { SpFileParser.new }

  describe "Special steps for sp file" do
    it "should get the multiline value for polynomials" do
      content = <<EOC
Somekey: someval\r
Polynomials: \r
  A: abc\r
  B: def\r
Apodize Data: val
EOC
      expected = { "Polynomials" => { "value" => "A: abc\r\n  B: def\r\n" , 'core' => false, 'supplied' => false } }
      metadata = parser.extract_metadata(StringIO.new(content))
      metadata.should == expected
    end
  end

  describe "Recognising SP files" do

    describe "recognising known SP file types" do
      it "should recognise Raman SP files" do
        file = mock(File)
        File.should_receive(:open).and_yield(file)
        file.should_receive(:read).and_return("PEPE2D sdfadsfad")
        parser.recognise?('/dummy/path').should be_true
      end
    end

    it "should not recognise other file types" do
      file = mock(File)
      File.should_receive(:open).and_yield(file)
      file.should_receive(:read).and_return("sdfadsfad")
      parser.recognise?('/dummy/path.sp').should be_false
    end
  end

end
