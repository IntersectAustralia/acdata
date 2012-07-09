require 'spec_helper'

describe SeoCode do
  describe "Validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :code }
  end

  describe "Potential Code Tests" do

    it "should return the correct number of results" do
      Factory(:seo_code, :name => "Chemistry", :code => "111111")
      Factory(:seo_code, :name => "Calculus", :code => "222222")
      Factory(:seo_code, :name => "Algebra", :code => "121212")
      Factory(:seo_code, :name => "Biology", :code => "212121")
      Factory(:seo_code, :name => "Physics", :code => "246321")

      SeoCode.potential_codes("C").count.should == 2
      SeoCode.potential_codes("Ch").count.should == 1
      SeoCode.potential_codes("1").count.should == 2
      SeoCode.potential_codes("2").count.should == 3
      SeoCode.potential_codes("463").count.should == 0
      SeoCode.potential_codes("lgebra").count.should == 0
    end

  end

end
