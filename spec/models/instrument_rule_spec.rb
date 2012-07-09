require 'spec_helper'

describe InstrumentRule do
  let(:file_type_a){ Factory(:instrument_file_type, :name => 'A') }
  let(:file_type_b){ Factory(:instrument_file_type, :name => 'B') }
  let(:file_type_c){ Factory(:instrument_file_type, :name => 'C') }
  let(:file_type_d){ Factory(:instrument_file_type, :name => 'D') }
  let(:file_type_e){ Factory(:instrument_file_type, :name => 'E') }
  let(:instrument_rule) {
    Factory(:instrument_rule,
            :metadata_list => "A",
            :indelible_list => "D",
            :unique_list => "A,B,C",
            :exclusive_list => "B,C",
            :visualisation_list => "E"
    )
  }

  describe "Names as a list" do
    it "should give a list of exclusive file names" do
      instrument_rule.exclusive_file_type_names.should == %w{B C}
    end

    it "should give a list of unique file names" do
      instrument_rule.unique_file_type_names.should == %w{A B C}
    end

    it "should give a list of indelible file names" do
      instrument_rule.indelible_file_type_names.should == %w{D}
    end

    it "should give a list of metadata file names" do
      instrument_rule.metadata_file_type_names.should == %w{A}
    end

    it "should give a list of visualisable file names" do
      instrument_rule.visualisation_file_type_names.should == %w{E}
    end

  end

  describe "Check if a file type is part of a given rule set" do
    it "indelible and metadata files should be indelible" do
      instrument_rule.indelible?(file_type_a).should be_true
      instrument_rule.indelible?(file_type_b).should be_false
      instrument_rule.indelible?(file_type_c).should be_false
      instrument_rule.indelible?(file_type_d).should be_true
      instrument_rule.indelible?(file_type_e).should be_false
    end

    it "should indicate if a file type is a metadata source" do
      instrument_rule.metadata?(file_type_a).should be_true
      instrument_rule.metadata?(file_type_b).should be_false
      instrument_rule.metadata?(file_type_c).should be_false
      instrument_rule.metadata?(file_type_d).should be_false
      instrument_rule.metadata?(file_type_e).should be_false
    end

    it "should indicate if a file type is visualisable" do
      instrument_rule.visualisable?(file_type_a).should be_false
      instrument_rule.visualisable?(file_type_b).should be_false
      instrument_rule.visualisable?(file_type_c).should be_false
      instrument_rule.visualisable?(file_type_d).should be_false
      instrument_rule.visualisable?(file_type_e).should be_true
    end

  end
end
