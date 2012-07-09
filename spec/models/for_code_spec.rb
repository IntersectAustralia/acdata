require 'spec_helper'

describe ForCode do
  describe "Validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :code }
  end

  describe "Potential Code Tests" do

    it "should return the correct number of results" do
      Factory(:for_code, :name => "Chemistry", :code => "111111")
      Factory(:for_code, :name => "Calculus", :code => "222222")
      Factory(:for_code, :name => "Algebra", :code => "121212")
      Factory(:for_code, :name => "Biology", :code => "212121")
      Factory(:for_code, :name => "Physics", :code => "246321")

      ForCode.potential_codes("C").count.should == 2
      ForCode.potential_codes("Ch").count.should == 1
      ForCode.potential_codes("1").count.should == 2
      ForCode.potential_codes("2").count.should == 3
      ForCode.potential_codes("463").count.should == 0
      ForCode.potential_codes("lgebra").count.should == 0
    end

  end
end
