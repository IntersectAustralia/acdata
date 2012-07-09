require 'spec_helper'

describe InstrumentManagementHelper do

  describe "find intrument file type" do

    it "finds it given the correct name" do
      instrument_file_type = Factory(:instrument_file_type, :name => 'test')
      helper.instrument_file_type_id('test').should == instrument_file_type.id
    end

  end

end
