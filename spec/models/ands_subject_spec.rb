require 'spec_helper'

describe AndsSubject do

  describe "Associations" do
    it { should have_and_belong_to_many :ands_publishables }
  end

  describe "Validations" do
    it { should validate_presence_of :keyword }
  end


  describe "Potential Code Tests" do

    it "should return the correct number of results" do
      Factory(:ands_subject, :keyword => "Chemistry")
      Factory(:ands_subject, :keyword => "Calculus")
      Factory(:ands_subject, :keyword => "Algebra")
      Factory(:ands_subject, :keyword => "Biology")
      Factory(:ands_subject, :keyword => "Physics")

      AndsSubject.potential_codes("C").count.should == 2
      AndsSubject.potential_codes("Ch").count.should == 1
      AndsSubject.potential_codes("Ch   ").count.should == 1
      AndsSubject.potential_codes("lgebra").count.should == 0
    end

  end
  
end
