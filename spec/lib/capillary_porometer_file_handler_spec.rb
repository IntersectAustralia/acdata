require 'spec_helper'

describe CapillaryPorometerFileHandler do

  describe "Recognising instrument file types" do
    it "should recognise Capillary Porometer xls files" do
      Dir.glob('sample_files/cp_*.xls').each do |filename|
        CapillaryPorometerXLSHandler.new.recognise?(filename).should be_true
      end
    end

    it "should recognise Capillary Porometer txt files" do
      Dir.glob('sample_files/cp_*.txt').each do |filename|
        CapillaryPorometerTXTHandler.new.recognise?(filename).should be_true
      end
    end
  end

  describe "Identifying Visualisable Test Methods" do
    describe "identify a test type from dataset metadata_values" do
      it "should return nil for a dataset without metadata_values" do
        dataset = Factory(:dataset)
        CapillaryPorometerFileHandler::test_type_from_metadata(dataset).should be_nil
      end

      it "should return the value of the 'Test Method' metadata_value" do
        dataset = Factory(:dataset)
        dataset.metadata_values.create(:key => 'Test Method', :value => 'Test')
        CapillaryPorometerFileHandler::test_type_from_metadata(dataset).should == 'Test'
      end

    end

    it "tests that are handled by CPBubblePoint are not visualisable" do
      CapillaryPorometerFileHandler::HANDLERS.keys.each do |name|
        next unless CapillaryPorometerFileHandler::HANDLERS[name] == 'CPBubblePoint'
        dataset = Factory(:dataset)
        dataset.metadata_values.create(:key => 'Test Method', :value => name)
        CapillaryPorometerFileHandler.visualisable?(dataset).should be_false
      end
    end

    it "should identify unknown tests as not visualisable" do
      dataset1 = Factory(:dataset)
      dataset1.metadata_values.create(:key => 'Test Method', :value => 'unknown')
      CapillaryPorometerFileHandler.visualisable?(dataset1).should be_false
    end

    it "should identify all known tests as visualisable" do
      CapillaryPorometerFileHandler::HANDLERS.keys.each do |name|
        next if CapillaryPorometerFileHandler::HANDLERS[name] == 'CPBubblePoint'
        dataset = Factory(:dataset)
        dataset.metadata_values.create(:key => 'Test Method', :value => name)
        CapillaryPorometerFileHandler.visualisable?(dataset).should be_true
      end
    end
  end

  describe "Metadata extraction strategy" do
    APP_CONFIG['chart_width'] = 600
    APP_CONFIG['chart_height'] = 400
    test_map = {
      'CAPILLARY FLOW ANALYSIS' => {
        'file' => 'sample_files/cp_POREDIST.xls',
        'strategy' => CPCapFlow,
        'metadata' => {"Operator"=>{"value"=>"Bob", "core"=>true , "supplied" => false}, "Lot Number"=>{"value"=>"Test 1", "core"=>true , "supplied" => false}, "Type of test"=>{"value"=>"Wet up, Dry down", "core"=>true , "supplied" => false}, "Wet Parameter"=>{"value"=>"Y:\\CAPLAB\\PARMS\\CUSTOMER\\EXAMPLES\\POREWET.TPF", "core"=>false , "supplied" => false}, "Dry Parameter"=>{"value"=>"Y:\\CAPLAB\\PARMS\\CUSTOMER\\EXAMPLES\\POREDRY.TPF", "core"=>false , "supplied" => false}, "Fluid"=>{"value"=>"PoreWick", "core"=>true , "supplied" => false}, "Surface Tension"=>{"value"=>"16.0 DYNES/CM", "core"=>false , "supplied" => false}, "File"=>{"value"=>"POREDIST.CFT", "core"=>true , "supplied" => false}, "Sample ID"=>{"value"=>"Sample A", "core"=>true , "supplied" => false}, "Mean Flow Pore Pressure"=>{"value"=>"13.263 PSI", "core"=>true , "supplied" => false}, "Mean Flow Pore Diameter"=>{"value"=>"0.5007 MICRONS", "core"=>true , "supplied" => false}, "Bubble Point Pressure"=>{"value"=>"5.469 PSI", "core"=>true , "supplied" => false}, "Bubble Point Pore Diameter"=>{"value"=>"1.2141 MICRONS", "core"=>true , "supplied" => false}, "Tortuosity"=>{"value"=>"0.715", "core"=>false , "supplied" => false}, "Std. Deviation of Avg. Pore Diameter"=>{"value"=>"0.2765", "core"=>false , "supplied" => false}, "Frazier analysis"=>{"value"=>"0.2096631 ft^3/min/ft^2 per 0.5 inches of water", "core"=>false , "supplied" => false},"Test Method"=>{"value"=>"CAPILLARY FLOW ANALYSIS", "core"=>false , "supplied" => false}},
        'graph_file' => 'sample_files/cp_POREDIST.png'
      },
      'BUBBLE POINT ANALYSIS' => {
        'file' => 'sample_files/cp_BUBBLEPT.txt',
        'strategy' => CPBubblePoint,
        'metadata' => {"Fluid"=>{"value"=>"POREWICK", "core"=>true , "supplied" => false}, "Surface Tension"=>{"value"=>"16 DYNES/CM", "core"=>false , "supplied" => false}, "File"=>{"value"=>"BUBBLEPT.CFT", "core"=>true , "supplied" => false}, "Sample ID"=>{"value"=>"Sample 131", "core"=>true, "supplied"=>false}, "Bubble Point Pressure"=>{"value"=>"0.464 PSI", "core"=>true , "supplied" => false}, "Bubble Point Pore Diameter"=>{"value"=>"14.3039 MICRONS", "core"=>true , "supplied" => false}, "Date & Time"=>{"value"=>"1992-03-12", "core"=>true , "supplied" => false}, "Test Method"=>{"value"=>"BUBBLE POINT ANALYSIS", "core"=>false , "supplied" => false}}
      },
      'PORE TABLE TEST ANALYSIS' => {
        'strategy' => CPBubblePoint,
        'file' => 'sample_files/cp_PORETABLE.txt',
        'metadata' => {"Date & Time"=>{"value"=>"2011-11-22", "core"=>true , "supplied" => false}, "Test Method"=>{"value"=>"PORE TABLE TEST ANALYSIS", "core"=>false , "supplied" => false}}
      },
      'PERMEABILITY RESULTS' => {
        'strategy' => CPPermeability,
        'file' => 'sample_files/cp_GASPERM.txt',
        'metadata' => {"Sample ID"=>{"value"=>"Sample 131", "core"=>true , "supplied" => false}, "File"=>{"value"=>"C:\\Program Files\\capwin\\data\\examples\\GASPERM.CFT", "core"=>true , "supplied" => false}, "Sample Thickness"=>{"value"=>"0.250 mm", "core"=>true , "supplied" => false}, " Sample Diameter"=>{"value"=>"42.000 mm", "core"=>true , "supplied" => false}, "Fluid"=>{"value"=>"AIR", "core"=>true , "supplied" => false}, "Fluid Viscosity"=>{"value"=>"0.019 CP", "core"=>false , "supplied" => false}, "Average Frazier Number"=>{"value"=>"0.28083", "core"=>false , "supplied" => false}, "Frazier analysis"=>{"value"=>".2675345 ft^3/min/ft^2 per 0.5 inches of water", "core"=>false , "supplied" => false}, "Date & Time"=>{"value"=>"1992-03-11 17:10:03", "core"=>true , "supplied" => false},  "Test Method"=>{"value"=>"PERMEABILITY RESULTS", "core"=>false , "supplied" => false}},
        'graph_file' => 'sample_files/cp_GASPERM.png'
      },
      'INTEGRITY TEST' => {
        'strategy' => CPIntegrity,
        'file' => 'sample_files/cp_INTEGRTY.txt',
        'metadata' => {"Fluid"=>{"value"=>"Porewick", "core"=>true , "supplied" => false}, "Surface Tension"=>{"value"=>"16 DYNES/CM", "core"=>false , "supplied" => false}, "File"=>{"value"=>"INTEGRTY.CFT", "core"=>true , "supplied" => false}, "Sample ID"=>{"value"=>"Sample 23c", "core"=>true , "supplied" => false}, "Date & Time"=>{"value"=>"1992-12-16", "core"=>true , "supplied" => false},  "Test Method"=>{"value"=>"INTEGRITY TEST", "core"=>false , "supplied" => false}},
        'graph_file' => 'sample_files/cp_INTEGRTY.png'
      },
      'PRESSURE HOLD TEST ANALYSIS' => {
        'strategy' => CPPressureHold,
        'file' => 'sample_files/cp_PRESHOLD.txt',
        'metadata' => {"Fluid"=>{"value"=>"AIR", "core"=>true , "supplied" => false}, "File"=>{"value"=>"C:\\Program Files\\capwin\\data\\examples\\PRESHOLD.CFT", "core"=>true , "supplied" => false}, "Sample ID"=>{"value"=>"Sample 131b", "core"=>true , "supplied" => false}, "Date & Time"=>{"value"=>"1992-12-03", "core"=>true , "supplied" => false},  "Test Method"=>{"value"=>"PRESSURE HOLD TEST ANALYSIS", "core"=>false , "supplied" => false}},
        'graph_file' => 'sample_files/cp_PRESHOLD.png'
      }
    }
    it "should choose the right strategy for the given test" do
      test_map.keys.each do |test_type|
        file_path = test_map[test_type]['file']
        expected_strategy = test_map[test_type]['strategy']
        parser = file_path.match(/.xls$/) ? CapillaryPorometerXLSHandler: CapillaryPorometerTXTHandler
        type = parser.get_test_type_from_file(File.join(Rails.root, file_path))
        type.should == test_type
        strategy = parser.get_strategy(type)
        strategy.should be_an_instance_of expected_strategy
      end
    end

    it "should parse and return metadata for each test type" do 
      test_map.keys.each do |test_type|
        file_path = test_map[test_type]['file']
        parser = file_path.match(/.xls$/) ? CapillaryPorometerXLSHandler : CapillaryPorometerTXTHandler
        metadata = parser.new.parse(file_path)
        metadata.should == test_map[test_type]['metadata']
      end
    end

    it "should create a graph for visualisable tests" do
      test_map.keys.each do |test_type|
        file_path = test_map[test_type]['file']
        builder = file_path.match(/.xls$/) ? CapillaryPorometerXLSHandler : CapillaryPorometerTXTHandler
        type = builder.get_test_type_from_file(File.join(Rails.root, file_path))
        
        strategy = builder.get_strategy(type)
        if strategy.respond_to?(:build)
          strategy.build(builder.get_content(file_path), 'tmp/cp-chart.png')
          if test_map[test_type].include?('graph_file')
            expected_digest = Digest::MD5.file(test_map[test_type]['graph_file']).hexdigest
            graph_digest = Digest::MD5.file('tmp/cp-chart.png').hexdigest
            graph_digest.should == expected_digest
          end
        end
      end
    end
  end
end
